$ ->	
	getData()
	$('.add').click(openQuickCreate)		
	$('.select .display').click(openSelect)
	$('.select .options input').change(updateSelectValue)
	$('.updateTemplate input').change(updateTemplate)
	return

getData = () ->
	$('.populate').each (i, container) ->
		createQuickAddForms(container)
		model = $(container).data('model')
		checked = $(container).data('checked')
		if(model=='parentLocation')
			model='location'
		type = $(container).data('type')
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
							addCheckbox(container, object, checked)
				$(container).addClass('loaded')
				return
		return
	return

addCheckbox = (container, object, checked) ->
	$clone = $(container).find('.sample').clone().removeClass('sample')
	$label = $clone.find('label')
	$input = $clone.find('input')
	$input.val(object.slug).attr('id', object.slug+'Checkbox')
	$label.text(object.name).attr('for', object.slug+'Checkbox')
	if checked
		if object.slug == checked || checked.indexOf(object.slug) > -1
			$input.attr('checked', true)
	$clone
		.attr('data-slug', object.slug)
		.appendTo(container)
	return

openSelect = (event) ->
	$select = $(event.target).parents('.select')
	datetype = $select.attr('data-datetype')
	$options = $select.find('.options')
	$select.siblings('.select').find('.options').removeClass('open')
	$options.toggleClass('open')
	return

updateSelectValue = (event) ->
	option = event.target 
	value = option.value
	$select = $(option).parents('.select')
	$options = $select.find('.options')
	$display = $select.find('.display')
	$display.html(value)
	$options.removeClass('open')
	return

createQuickAddForms = (container) ->
	type = $(container).data('model')
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
	$submit = $addForm.find('input[type="submit"]')
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
			return addCheckbox(checkboxes, JSON.parse(object))
	return

updateTemplate = (event) ->
	$input = $(event.target)
	value = $input.val()
	$('[data-template]').removeClass('show')
	$('[data-template="'+value+'"]').addClass('show')
