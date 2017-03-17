$ ->
	$window = $(window)
	$body = $('body')
	$map = $('#map')
	$intro = $('#intro')
	$introCanvas = $('#intro')
	$right = $('aside#right')
	$left = $('aside#left')
	markersLayer = []
	window.markers = {}
	nycLatLng = {lat: 40.723952837100995, lng: -73.98725835012341}
	zoomIn = 15
	zoomOut = 12
	minZoom = 9.8
	maxZoom = 20

	initMap = () ->
		mapboxgl.accessToken = 'pk.eyJ1IjoiY29yZXl0ZWdlbGVyIiwiYSI6ImNpd25xZHV3cjAxMngyenFpeGd0aGxwanYifQ.quHbdI63gF-JNfVLCe_fTw'
		window.map = new mapboxgl.Map
		  container: 'map',
		  style: 'mapbox://styles/coreytegeler/ciwnq6zxd004o2ppllvfpmx5x',
		  center: nycLatLng,
		  speed: 2,
		  zoom: zoomOut,
		  minZoom: minZoom,
		  maxZoom: maxZoom,
		  pitch: 15
		map.on 'load', () ->
			getPoints()
			# introSetup()
			# getFeature('boroughs')
			$map.addClass('show')

	getFeature = (featureName) ->
		url = '/geojson/' + featureName + '.json'
		$.getJSON
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (geojson, status, jqXHR) ->
				map.addSource featureName,
					'type': 'geojson',
					'data': geojson
				map.addLayer({
		    	'id': featureName,
		    	'type': 'line',
					'source': featureName
				})
		return

	introSetup = () ->
		$.each map.queryRenderedFeatures(), (i, layer) ->
			id = layer.layer.id
			if id == 'background'
				console.log layer
			map.setLayoutProperty(id, 'visibility', 'none')

	getPoints = () ->
		url = '/api/json/?type=location'
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				plotMarkers(response)
				if($right.is('.open'))
					id = $right.data('id')
					centerPoint(id)
		return

	plotMarkers = (locs) ->
		markersArray = []
		bounds = new mapboxgl.LngLatBounds()
		$.each locs, (i, loc) ->
			marker = plotMarker(loc)
			# getLocActions(loc, marker)
			bounds.extend(marker.geometry.coordinates)
			markersArray.push(marker)
			markers[loc._id] = marker
		listLocs(locs)
		map.addSource 'markers',
	    'type': 'geojson',
	    'data':
        'type': 'FeatureCollection',
        'features': markersArray

    map.addLayer({
    	'id': 'markers',
			'source': 'markers',
			'type': 'circle',
			'paint':
				'circle-radius': 6,
				'circle-color': colors.darker
		})
		map.fitBounds bounds,
			padding: 50,
			animate: false
		map.on 'mousemove', mapMouseMove
		map.on 'click', mapClick

	plotMarker = (loc) ->
		if(!loc.point)
			return
		lng = loc.point.longitude
		lat = loc.point.latitude
		marker = {
	    'type': 'Feature',
	    'geometry': {
        'type': 'Point',
        'coordinates': [lng, lat]
	    },
	    'properties': {
	    	'id': loc._id,
	    	'title': loc.name,
	    	'name': loc.name,
	    	'slug': loc.slug,
	    	'address': loc.pointAddress
	    }
		}
		return marker	

	# clickMarker = (marker) ->
	# 	getLocContent(marker)
	# 	marker.closePopup()
	# 	$('.marker.selected').removeClass('selected')
	# 	$(marker._path).addClass('selected')

	getLocContent = (id, title) ->
		url = '/api/html/?type=location&id='+id
		# marker = markers[id]
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				openLocPanel(id, title, response)
		return

	openLocPanel = (id, title, response) ->
		$right.find('.title h1').html title
		if(!$.isEmptyObject(markers))
			centerPoint(id)
		getLocActions(id)
		$right.find('.content').html(response)
		$right.attr('data-id', id)
		$right.addClass('show')
		$right.addClass('open')
		$left.removeClass('open')

	centerPoint = (id) ->
		marker = markers[id]
		latlng = marker.geometry.coordinates
		currentZoom = map.getZoom()
		zoomOffset = currentZoom/zoomIn
		pixelCoords = map.project marker.geometry.coordinates
		xOffset = 0.375 * map._containerDimensions()[0]
		pixelCoords.x = pixelCoords.x + xOffset
		flyTo = map.unproject pixelCoords
		$map.attr 'data-zoom', currentZoom
		map.flyTo
			center: flyTo,
			curve: 1,
      bearing: 0,
      speed: .1

	getLocActions = (id) ->
		url = '/api/html/?type=action&filter=location&id='+id
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (content, status, jqXHR) ->
				listLocActions(id, content)

	listLocActions = (id, content) ->
		$content = $(content)
		$actions = $right.find('.actions')
		$actions.append($content)
		$content.imagesLoaded().progress (inst, image) ->
			$img = $(image.img)
			$image = $img.parent()
			$image.addClass('loaded')

	closeRight = (e) ->
		$right.removeClass('open')
		zoomTo = $map.attr 'data-zoom'
		if zoomTo
			map.zoomTo zoomTo

	getUniqueFeatures = (array, comparatorProperty) ->
    existingFeatureKeys = {}
    uniqueFeatures = array.filter (el) ->
      if (existingFeatureKeys[el.properties[comparatorProperty]])
        return false
      else
        existingFeatureKeys[el.properties[comparatorProperty]] = true
        return true

    return uniqueFeatures

	listLocs = (locs) ->
		$leftList = $left.find('ul')
		$leftList.html ''
		$.each locs, (id, loc) ->
			id = loc._id
			slug = loc.slug
			name = loc.name
			address = loc.pointAddress
			url = getUrl('location', slug)
			$locLink = $('<li class="loc link"><a href="'+url+'" data-id="'+id+'" data-title="'+name+'"><div class="name">'+name+'</div><div class="address">'+address+'</div></div></li>')
			$leftList.append $locLink
		$left.addClass('show')
		if(!$right.is('.open'))
			$left.addClass('open')

	mapMouseMove = (e) ->
		features = map.queryRenderedFeatures e.point,
			layers: ['markers']
		if features.length
			map.getCanvas().style.cursor = 'pointer'
		else
			map.getCanvas().style.cursor = ''

	mapClick = (e) ->
		features = map.queryRenderedFeatures e.point,
			layers: ['markers']
		if features.length
			marker = features[0]
			id = marker.properties.id
			title = marker.properties.title
			getLocContent(id, title)

	clickLocLink = (e) ->
		e.preventDefault()
		id = this.dataset.id
		title = this.dataset.title
		getLocContent(id, title)

	getUrl = (model, slug) ->
		root = $body.data('root')
		root = '/'
		return root+model+'/'+slug

	readUrl = () ->
		id = $body.data('id')
		model = $body.data('model')
		switch model
		  when 'location'
		  	getLocContent(id)
		  	break

	windowResizing = () ->
		$('aside').addClass('static')
		clearTimeout(window.timeout)
		window.timeout = setTimeout(windowResized, 300)

	windowResized = () ->
		$('aside').removeClass('static')

	$body.on 'click touchend', '.right.open .band', closeRight
	$body.on 'change', '#points input', listLocs
	$body.on 'click', '.locations ul li.loc a', clickLocLink
	$window.on 'resize', windowResizing

	$palette = $('#palette')
	colors = {
		white: $palette.find('.white').css('color')
		light: $palette.find('.light').css('color')
		medium: $palette.find('.medium').css('color')
		dark: $palette.find('.dark').css('color')
		darker: $palette.find('.darker').css('color')
		black: $palette.find('.black').css('color')
		yellow: $palette.find('.yellow').css('color')
	}
	readUrl()
	initMap()