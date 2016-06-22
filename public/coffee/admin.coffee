$ ->	
	getData()
	return

getData = () ->
	$('.populate').each (i, container) ->
		model = $(container).data('pop-model')
		type = $(container).data('pop-type')
		$.ajax
			url: '/api/'+model+'/all/json'
			error:  (jqXHR, status, error) ->
				console.log jqXHR, status, error
				return
			success: (objects, status, jqXHR) ->
				switch type
					when 'checkboxes'
						populateCheckboxes
				populateCheckboxes container, objects
				return
		return
	return

populateCheckboxes = (container, items) ->
	$(items).each (i, item) ->
		$clone = $(container).find('.sample').clone().removeClass('sample')
		$label = $clone.find('span')
		$input = $clone.find('input')
		$label
			.attr('name', item.slug)
			.text(item.name)
		$input
			.attr('name', item.slug)
		$clone
			.attr('data-slug', item.slug)
			.appendTo(container)
		return
	return
