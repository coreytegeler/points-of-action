$ ->
	$window = $(window)
	$body = $('body')
	$body.on 'click touchend', '.band', toggleFloat

window.toggleFloat = (aside, dur) ->
	if($(aside).is('aside'))
		$aside = $(aside)
		$band = $aside.find('.band')
	else
		$band = $(this)
		$aside = $band.parents('aside')
	$aside.toggleClass('open')