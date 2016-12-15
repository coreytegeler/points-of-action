$ ->
	$window = $(window)
	$body = $('body')
	$map = $('#map')
	$right = $('#right.float')
	$left = $('#left.float')
	markersLayer = []
	nycLatLng = {lat: 40.723952837100995, lng: -73.98725835012341}
	zoomIn = 17
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
			getMarkers()
			getFeature('boroughs')
			$map.addClass('show')
			map.on 'moveend', listLocations

	getFeature = (featureName) ->
		url = '/geojson/' + featureName + '.json'
		$.getJSON
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				map.addSource featureName,
					'type': 'geojson',
					'data': response
				map.addLayer({
		    	'id': featureName,
		    	'type': 'line',
					'source': featureName
				})
		return

	getMarkers = () ->
		url = '/api/?type=location'
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				plotMarkers(response)
		return

	plotMarkers = (locs) ->
		window.markers = []
		bounds = new mapboxgl.LngLatBounds()
		$.each locs, (i, loc) ->
			marker = plotMarker(loc)
			# getLocActions(loc, marker)
			bounds.extend(marker.geometry.coordinates)
			markers.push(marker)
		map.addSource 'markers',
	    'type': 'geojson',
	    'data':
        'type': 'FeatureCollection',
        'features': markers

    map.addLayer({
    	'id': 'markers',
			'source': 'markers',
			'type': 'circle',
			'paint':
				'circle-radius': 6,
				'circle-color': colors.yellow
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
		

	# getLocActions = (loc, marker) ->
	# 	url = '/api/?type=action&filter=location&id='+loc._id
	# 	$.ajax
	# 		url: url,
	# 		error:  (jqXHR, status, error) ->
	# 			console.error jqXHR, status, error
	# 			return
	# 		success: (actions, status, jqXHR) ->
	# 			marker.setStyle
	# 				radius: markerRadius + (actions.length*2)
	# 			listLocActions(loc, marker, actions)

	# listLocActions = (loc, marker, actions) ->
	# 	$popup = $('.popup.sample').clone()
	# 	$popup
	# 		.removeClass('sample')
	# 		.addClass('location')
	# 		.attr('data-id', loc._id)
	# 	$.each actions, (i, action) ->
	# 		$action = $('<li><a href="/?type=action&id='+action._id+'">'+action.name+'</a></li>')
	# 		$popup.find('ul').append($action)
	# 	# popup = marker.bindPopup($popup.html())

	# clickMarker = (marker) ->
	# 	getLocContent(marker)
	# 	marker.closePopup()
	# 	$('.marker.selected').removeClass('selected')
	# 	$(marker._path).addClass('selected')

	getLocContent = (marker) ->
		id = marker.properties.id
		title = marker.properties.title
		url = '/content/?type=location&id='+id
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

		$right.find('.title h1').html title
		if(!$body.is('.opened'))
			position = marker._vectorTileFeature
			x = position._x
			y = position._y
			# 	flyTo = map.containerPointToLayerPoint([x + $map.innerWidth()/2.666, y])
			# else
		flyTo = marker.geometry.coordinates
		$map.attr 'data-zoom', map.getZoom()
		map.flyTo
			center: flyTo,
			curve: 1,
			zoom: zoomIn,
      bearing: 0,
      speed: .1
    $body.addClass('opened')

		$left.transition
			x: -$window.innerWidth(),
    	scale: .9
    , 500, 'easeInOutQuint'

		$right.transition
    	x: 0,
    	scale: 1
		, 500, 'easeInOutQuint', () ->
    	console.log '!'
    	$right.find('.content').html(response)
			$right.find('.lead').imagesLoaded () ->
				$(this.elements[0]).addClass('loaded')
				imagesLoaded($right).on 'progress', (inst, image) ->
					$(image.img).addClass('loaded')


	closeRight = (e) ->
		$body.removeClass('opened')
		$right.transition
    	x: $window.innerWidth(),
    	scale: .9
    $left.transition
    	x: 0,
    	scale: 1
		zoomTo = $map.attr 'data-zoom'
		map.zoomTo zoomTo

	closeFloater = (e) ->
		$floater = $(this).parents '.float'
		$floater.toggleClass 'hide'

	getUniqueFeatures = (array, comparatorProperty) ->
    existingFeatureKeys = {}
    uniqueFeatures = array.filter (el) ->
      if (existingFeatureKeys[el.properties[comparatorProperty]])
        return false
      else
        existingFeatureKeys[el.properties[comparatorProperty]] = true
        return true

    return uniqueFeatures

	listLocations = (e) ->
		# if $left.find('#inView')[0].checked
		# 	markers = map.queryRenderedFeatures
		# 		layers: ['markers']
		# else
		markers = window.markers
		# getUniqueFeatures(markers, "iata_code")
		$leftList = $left.find('ul')
		$leftList.html ''
		markers.forEach (marker) ->
			id = marker.properties.id
			slug = marker.properties.slug
			name = marker.properties.name
			address = marker.properties.address
			$leftList.append '<li data-id="' + id + '"><div class="name">' + name + '</div><div class="address">' + address + '</div></li>'

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
			getLocContent(marker)


	$body.on 'click touchend', '#right .band', closeRight
	$body.on 'click touchend', '.float .band.top', closeFloater
	$body.on 'change', '#points input', listLocations


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