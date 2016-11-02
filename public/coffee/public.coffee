$ ->
	$map = $('#map')
	$aside = $('aside')
	pointsLayer = []
	
	initMap = () ->
		window.map = L.map 'map',
			center: [40.7128, -74.0059],
			zoom: 10

		tiles = L.tileLayer 'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
			attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
			subdomains: 'abcd',
			minZoom: 10,
			zoom: {
				animate: false
			}
		.addTo(map)

		getPoints()

	getPoints = () ->
		url = '/api/?type=location'
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				plotPoints(response)
		return

	plotPoints = (locs) ->
		points = []
		$.each locs, (i, loc) ->
			point = plotPoint(loc)
			getLocActions(loc, point)
			point.addTo(map)
			points.push(point._latlng)
		if(points.length)
			map.fitBounds points,
				padding: [50,50],
				animate: false
		$map.addClass('show')

	pointRadius = 8
	plotPoint = (loc) ->
		if(!loc.point)
			return
		lat = loc.point.latitude
		lng = loc.point.longitude
		point = new L.circleMarker([lat,lng], {
			type: loc.type,
			id: loc._id,
			slug: loc.slug,
			fillOpacity: 1,
			weight: 2,
			radius: pointRadius,
			className: 'point'
		})
		.on 'mouseover', () ->
			$(this._path).addClass('hover')
			if(!$(this._path).is('.selected'))
				this.openPopup()
		.on 'mouseout', () ->
			$(this._path).removeClass('hover')
			this.closePopup()
		.on 'click', (e) ->
			clickPoint(this)
		return point

	getLocActions = (loc, point) ->
		url = '/api/?type=action&filter=location&id='+loc._id
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (actions, status, jqXHR) ->
				point.setStyle
					radius: pointRadius + (actions.length*2)
				listLocActions(loc, point, actions)

	listLocActions = (loc, point, actions) ->
		$popup = $('.popup.sample').clone()
		$popup
			.removeClass('sample')
			.addClass('location')
			.attr('data-id', loc._id)
		$.each actions, (i, action) ->
			$action = $('<li><a href="/?type=action&id='+action._id+'">'+action.name+'</a></li>')
			$popup.find('ul').append($action)
		# popup = point.bindPopup($popup.html())

	clickPoint = (point) ->
		getLocContent(point)
		point.closePopup()
		$('.point.selected').removeClass('selected')
		$(point._path).addClass('selected')

	getLocContent = (point) ->
		type = point.options.type
		id = point.options.id
		url = '/content/?type='+type+'&id='+id
		$.ajax
			url: url,
			error:  (jqXHR, status, error) ->
				console.error jqXHR, status, error
				return
			success: (response, status, jqXHR) ->
				openLoc(type, id, response, point)
		return

	openLoc = (type, id, response, point) ->
		$aside.find('.content').html(response)
		$aside.find('.lead').imagesLoaded () ->
			$(this.elements[0]).addClass('loaded')
			imagesLoaded($aside).on 'progress', (inst, image) ->
				$(image.img).addClass('loaded')
			latlng = point._latlng
			if(!$map.is('.thin'))
				latlngPixel = map.latLngToLayerPoint(latlng)
				latlng = map.layerPointToLatLng([latlngPixel.x + $map.innerWidth()/2.666, latlngPixel.y])
			setTimeout () ->
				map.invalidateSize()
				map.panTo(latlng)
				$aside.addClass('show')
				$map.addClass('thin')
				map.invalidateSize()
			, 100

	initMap()