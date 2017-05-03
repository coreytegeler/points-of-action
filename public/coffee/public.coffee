$ ->
	$window = $(window)
	$body = $('body')
	$map = $('#map')
	$intro = $('#intro')
	$right = $('aside#right')
	$left = $('aside#left')
	markersLayer = []
	window.markers = {}
	nycLatLng = {lat: 40.723952837100995, lng: -73.98725835012341}
	zoomIn = 15
	zoomOut = 12
	minZoom = 9.8
	maxZoom = 20

	init = () ->
		readUrl()
		initMap()
		watchAsides()

	initMap = () ->
		mapboxgl.accessToken = 'pk.eyJ1IjoiY29yZXl0ZWdlbGVyIiwiYSI6ImNpd25xNjU0czAyeG0yb3A3cjdkc2NleHAifQ.EJAjj38qZXzIylzax3EMWg'
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
			introSetup()
			createMask()
			adjustMapWrap()
			winResize()

	getFeature = (featureName) ->
		url = '/geojson/' + featureName + '.json'
		return $.ajax
			url: url,
			datatype: 'json',
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (geojson, status, jqXHR) ->
				return geojson

	createMask = () ->
		$.when(getFeature('nyc'), getFeature('boroughs')).done (nyc, boroughs) ->
			nyc = nyc[0]
			boroughs = boroughs[0]
			nycFeature = turf.combine(nyc).features[0]
			boroughsFeature = turf.combine(boroughs)
			nycBounds = turf.bbox(nycFeature)
			nycPoly = turf.bboxPolygon(nycBounds)
			nycBoundsBuffer = turf.buffer(nycPoly, 20, 'miles')
			nycPolyBuffer = turf.buffer(nycPoly, 100, 'miles')
			mask = turf.difference(nycPolyBuffer, nycFeature)
			map.setMaxBounds(turf.bbox(nycBoundsBuffer))
			map.addSource 'nyc-mask',
				'type': 'geojson',
				'data': mask
			map.addLayer({
	    	'id': 'nyc-mask',
	    	'type': 'fill',
				'source': 'nyc-mask',
				'paint': {
					'fill-color': '#addef0'
					'fill-opacity': 0.999
				}
			})

	introSetup = () ->
		return

	getPoints = () ->
		url = '/api/json/?model=location'
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
			marker = plotMarker(loc, i)
			# getLocActions(loc, marker)
			bounds.extend(marker.geometry.coordinates)
			markersArray.push(marker)
			markers[loc._id] = marker
		# listLocs(locs)

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
				'circle-color': 'transparent'
		})
		# map.setMaxBounds bounds
		map.fitBounds bounds,
			padding: 50,
			animate: false
		map.on 'mousemove', mapMouseMove
		$body.addClass('intro')
		begin()

	plotMarker = (loc, i) ->
		if(!loc.point)
			return
		lng = loc.point.longitude
		lat = loc.point.latitude

		point = document.createElement('div')
		new mapboxgl.Marker(point)
			.setLngLat([lng, lat])
			.addTo(map) 

		$point = $(point)
			.addClass('point')
			.attr('data-id', loc._id)
    	.attr('data-title', loc.name)
    	.attr('data-name', loc.name)
    	.attr('data-slug', loc.slug)
    	.attr('data-address', loc.pointAddress)

		setTimeout () ->
    	$point.addClass('show')
  	, 10*i   

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

	begin = () ->
		$body.removeClass('intro')
		$body.addClass('map')
		$left.addClass('show').addClass('open')

	getLocContent = (id, title) ->
		url = '/api/html/?model=location&id='+id
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
		$right.find('header h2').html title
		$right.find('.band a .text').html '<label>Location:</label>'+title
		if(!$.isEmptyObject(markers))
			centerPoint(id)
		getLocActions(id)
		$right.find('.content').html(response)
		$right.attr('data-id', id)
		$right.addClass('show')
		$right.addClass('open')
		$left.removeClass('open')
		adjustMapWrap()

	centerPoint = (id) ->
		marker = markers[id]
		latlng = marker.geometry.coordinates
		currentZoom = map.getZoom()
		zoomOffset = currentZoom/zoomIn
		# pixelCoords = map.project marker.geometry.coordinates
		# xOffset = 0.375 * map._containerDimensions()[0]
		# pixelCoords.x = pixelCoords.x + xOffset
		# flyTo = map.unproject pixelCoords
		flyTo = marker.geometry.coordinates
		$map.attr 'data-zoom', currentZoom
		map.flyTo
			center: flyTo,
			curve: 1,
      bearing: 0,
      speed: .1

	getLocActions = (id) ->
		url = '/api/html/?model=action&filter=location&id='+id
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

  listModel = (e) ->
  	e.preventDefault()
  	$a = $(this)
  	$row = $a.parents('.row')
  	model = $row.attr('data-model')
  	url = '/api/json/?model='+model
  	console.log url
  	$.ajax
  		url: url,
  		error:  (jqXHR, status, error) ->
  			console.error jqXHR, status, error
  			return
  		success: (list, status, jqXHR) ->
  			$.each list, (i, item) ->
  				$ul = $row.parents('.group').find('.bricks.'+model)
  				$ul.append('<div class="brick">'+item.name+'</div>')


	mapMouseMove = (e) ->
		features = map.queryRenderedFeatures e.point,
			layers: ['markers']
		if features.length
			map.getCanvas().style.cursor = 'pointer'
		else
			map.getCanvas().style.cursor = ''

	clickLocLink = (e) ->
		e.preventDefault()
		id = this.dataset.id
		title = this.dataset.title
		getLocContent(id, title)

	clickPoint = (e) ->
		id = $(this).attr('data-id')
		title = $(this).attr('data-title')
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

	watchAsides = () ->
		# mutantWatcher = new MutationObserver (mutations) ->
		#   mutations.forEach (mutation) ->
		  	# if mutation.type == 'attributes'
		  	# 	adjustMapWrap()

		# $('aside').each (i, aside) ->
		# 	mutantWatcher.observe aside,
		# 	  attributes: true

	toggleAside = (e) ->
		$band = $(this)
		$aside = $band.parents('aside')
		$aside.toggleClass('open')
		if $aside.is('#right.open')
			$left.removeClass('open')
		adjustMapWrap()

	adjustMapWrap = () ->
		leftWidth = $left.innerWidth()
		rightWidth = $right.innerWidth()
		mapWidth = $window.innerWidth()
		marginLeft = 0
		marginRight = 0
		if $left.is('.open')
			mapWidth -= leftWidth
			marginLeft = leftWidth
			dur = $left.css('transition-duration')
		if $right.is('.open')
			mapWidth -= rightWidth
			marginRight = rightWidth
		$map.css
			width: mapWidth
			marginLeft: marginLeft
			marginRight: marginRight

	winResize = () ->
		$('aside').addClass('static')
		adjustMapWrap()
		clearTimeout(window.timeout)
		window.timeout = setTimeout(winResized, 300)

	winResized = () ->
		$('aside').removeClass('static')

	$body.on 'click', '.locations ul li.loc a', clickLocLink
	$body.on 'click', '#map .point', clickPoint
	$body.on 'click touchend', '.band', toggleAside
	$body.on 'click touchend', '#begin', begin
	$body.on 'click touchend', '.contents a.model', listModel

	$window.on 'resize', winResize

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
	init()