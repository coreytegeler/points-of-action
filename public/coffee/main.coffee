$ ->
	$window = $(window)
	$body = $('body')
	$body.on 'click touchend', '.band', toggleFloat

window.toggleFloat = (float, dur) ->
	if($(float).is('.float'))
		$float = $(float)
		$band = $float.find('.band')
	else
		$band = $(this)
		$float = $band.parents('.float')
	$float.toggleClass('open')