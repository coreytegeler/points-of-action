$ ->	
	getData()
	fillDateSelects()
	$('body').on('click', '.add', openQuickCreate)
	$('body').on('click', '.select .display', openSelect)
	$('body').on('change', '.select .options input', updateSelectValue)
	$('body').on('change', '.updateTemplate input', updateTemplate)
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
	return $clone

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
	$saveBtn = $addForm.find('input.save')
	$cancelBtn = $addForm.find('input.cancel')
	$saveBtn.click(quickCreate)
	$cancelBtn.click(closeQuickCreate)
	$('body').addClass('noScroll')
	return

closeQuickCreate = (event) ->
	event.preventDefault()
	$button = $(event.target)
	$addForm = $addForm = $button.parents('.quickCreate')
	$addForm.removeClass('open')
	$('body').removeClass('noScroll')
	clearQuickCreate($addForm)
	return

clearQuickCreate = (addForm) ->
	$(addForm).find('input, textarea').each (i, input) ->
		type = $(input).attr('type')
		if(type == 'text' || input == 'password' || input == 'email')
			$(input).val('')
		else if (type == 'checkbox' || type == 'radio')
			$(input).prop('checked', false);
	$(addForm).find('[data-template]').each (i, group) ->
		$(group).removeClass('show')
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
			$('body').removeClass('noScroll')
			$quickCreate.removeClass('open')
			clearQuickCreate($quickCreate)
			object = JSON.parse(object)
			addCheckbox(checkboxes, object, object.slug)
			return
	return

updateTemplate = (event) ->
	$input = $(event.target)
	$form = $input.parents('form')
	value = $input.val()
	console.log($input)
	$form.find('[data-template]').removeClass('show')
	$form.find('[data-template="'+value+'"]').addClass('show')

fillDateSelects = () ->
	$('.date.selects').each (i, selects) ->
		$monthOptions = $(selects).find('.options.months')
		$sample = $monthOptions.find('.checkbox.sample')
		for i in [0...12]
			month = moment.months(i)
			days = moment(i+1, 'M').daysInMonth()
			object = {name: month, slug: month}
			$checkbox = addCheckbox($monthOptions, object, [])
			$checkbox.attr('data-days', days)

		$dayOptions = $(selects).find('.options.days')
		$sample = $dayOptions.find('.checkbox.sample')
		for i in [1..31]
			object = {name: i, slug: i}
			$checkbox = addCheckbox($dayOptions, object, [])

		$yearOptions = $(selects).find('.options.years')
		$sample = $yearOptions.find('.checkbox.sample')
		for i in [moment().year()...1899]
			object = {name: i, slug: i}
			$checkbox = addCheckbox($yearOptions, object, [])