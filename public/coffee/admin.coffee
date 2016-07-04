$ ->	
	getData()
	$('.add').click(openQuickCreate)		
	return

getData = () ->
	$('.populate').each (i, container) ->
		createQuickAddForms(container)
		model = $(container).data('pop-model')
		type = $(container).data('pop-type')
		$.ajax
			url: '/api/'+model+'/all/json'
			error:  (jqXHR, status, error) ->
				console.log jqXHR, status, error
				return
			success: (objects, status, jqXHR) ->
				if(!objects)
					return
				switch type
					when 'checkboxes'
						$(objects).each (i, object) ->
							addCheckbox container, object
				return
		return
	return

addCheckbox = (container, object) ->
	$clone = $(container).find('.sample').clone().removeClass('sample')
	$label = $clone.find('span')
	$input = $clone.find('input')
	$label
		.attr('name', object.slug)
		.text(object.name)
	$input
		.attr('name', object.slug)
	$clone
		.attr('data-slug', object.slug)
		.appendTo(container)
	return

createQuickAddForms = (container) ->
	type = $(container).data('pop-model')
	$.ajax
		url: '/admin/'+type+'/quick-create'
		error: (jqXHR, status, error) ->
			console.log jqXHR, status, error
			return
		success: (html, status, jqXHR) ->
			if(!html)
				return
			return $('.quickCreates').append(html)
	return

openQuickCreate = (event) ->
	$button = $(event.target)
	type = $button.data('model')
	$module = $button.parents('.module')
	$addForm = $('.quickCreate[data-model="'+type+'"]')
	$addForm.addClass('open')
	$submit = $addForm.find('.submit')
	$submit.click(quickCreate)
	return

quickCreate = (event) ->
	event.preventDefault()
	$quickCreate = $(event.target).parents('.quickCreate')
	$form = $quickCreate.find('form')
	postUrl = $form.attr('action')
	data = $form.serializeArray()
	type = $quickCreate.data('model')
	checkboxes = $('.checkboxes.'+type);
	$.ajax
		type: 'POST',
		data: data,
		url: postUrl,
		dataType: 'HTML',
		error: (jqXHR, status, error) ->
			return console.log(jqXHR, status, error)
		success: (object, status, jqXHR) ->
			$quickCreate.removeClass('open')
			console.log(object)
			return addCheckbox checkboxes, JSON.parse(object)
	return

	
