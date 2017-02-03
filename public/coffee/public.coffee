$ ->
	$window = $(window)
	$body = $('body')
	$map = $('#map')
	$intro = $('#intro')
	$introCanvas = $('#intro')
	$right = $('#right.float')
	$left = $('#left.float')
	markersLayer = []
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
			getFeature('boroughs')
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
		return

	plotMarkers = (locs) ->
		window.markers = {}
		markersArray = []
		bounds = new mapboxgl.LngLatBounds()
		$.each locs, (i, loc) ->
			marker = plotMarker(loc)
			# getLocActions(loc, marker)
			bounds.extend(marker.geometry.coordinates)
			markersArray.push(marker)
			markers[loc._id] = marker
		listLocs()
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
		marker = markers[id]
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				openLocPanel(id, title, response, marker)
		return

	openLocPanel = (id, title, response, marker) ->
		latlng = marker.geometry.coordinates
		currentZoom = map.getZoom()
		$right.find('.title h1').html title
		# if(!$body.is('.opened'))
		zoomOffset = currentZoom/zoomIn
		pixelCoords = map.project marker.geometry.coordinates
		xOffset = 0.375 * map._containerDimensions()[0]
		pixelCoords.x = pixelCoords.x + xOffset
		flyTo = map.unproject pixelCoords
		$map.attr 'data-zoom', currentZoom
		$right.find('.content').html(response)
		getLocActions(id)
		map.flyTo
			center: flyTo,
			curve: 1,
			# zoom: zoomIn,
      bearing: 0,
      speed: .1

		$right.addClass('show')
		$right.addClass('open')
		$left.removeClass('open')

	getLocActions = (id) ->
		url = '/api/html/?type=action&filter=location&id='+id
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (content, status, jqXHR) ->
				listLocActions(content)

	listLocActions = (content) ->
		$actions = $right.find('.actions')
		$actions.append(content)

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

	listLocs = (e) ->
		# markers = window.markers
		$leftList = $left.find('ul')
		$leftList.html ''
		$.each markers, (id, marker) ->
			id = marker.properties.id
			slug = marker.properties.slug
			name = marker.properties.name
			address = marker.properties.address
			$leftList.append '<li class="loc-link" data-id="' +id+'" data-title="'+name+'"><div class="name">'+name+'</div><div class="address">'+address+'</div></li>'
		$left.addClass('open').addClass('show')

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

	clickLocLink = () ->
		id = this.dataset.id
		title = this.dataset.title
		getLocContent(id, title)

	$body.on 'click touchend', '.right.open .band', closeRight
	$body.on 'change', '#points input', listLocs
	$body.on 'click', '.loc-link', clickLocLink


	colors = {
		white: $('#palette .white').css('color')
		light: $('#palette .light').css('color')
		medium: $('#palette .medium').css('color')
		dark: $('#palette .dark').css('color')
		darker: $('#palette .darker').css('color')
		black: $('#palette .black').css('color')
		yellow: $('#palette .yellow').css('color')
	}
	initMap()