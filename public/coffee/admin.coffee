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
			url: '/api/?type='+model+'&format=json'
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
	$clone = $(container).find('.null').clone()
	$clone.removeClass('null')
	$label = $clone.find('label')
	$input = $clone.find('input')
	$input.val(object._id).attr('id', object.slug+'-checkbox')
	$label.text(object.name).attr('for', object.slug+'-checkbox')
	if checked
		if object._id == checked || checked.indexOf(object._id) > -1
			$input.attr('checked', true)
	$clone
		.attr('data-value', object._id)
		.appendTo(container)

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
		url: '/admin/'+type+'/quicky'
		error: (jqXHR, status, error) ->
			console.log jqXHR, status, error
			return
		success: (html, status, jqXHR) ->
			if(!html)
				return
			return $('.quickies').append(html)
	return

openQuickCreate = (event) ->
	$button = $(event.target)
	type = $button.data('model')
	$module = $button.parents('.module')
	$addForm = $('.quicky[data-model="'+type+'"]')
	$addForm.addClass('open')
	$saveBtn = $addForm.find('input.save')
	$cancelBtn = $addForm.find('input.cancel')
	$saveBtn.one 'click', quicky
	$cancelBtn.one 'click', closeQuickCreate
	$('body').addClass('noScroll')
	return

closeQuickCreate = (event) ->
	event.preventDefault()
	$button = $(event.target)
	$addForm = $addForm = $button.parents('.quicky')
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

quicky = (event) ->
	event.preventDefault()
	$quicky = $(event.target).parents('.quicky')
	$form = $quicky.find('form')
	postUrl = $form.attr('action')
	data = $form.serializeArray()
	type = $quicky.data('model')
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
			$quicky.removeClass('open')
			clearQuickCreate($quicky)
			object = JSON.parse(object)
			addCheckbox(checkboxes, object, object.slug)
			return
	return

updateTemplate = (event) ->
	$input = $(event.target)
	$form = $input.parents('form')
	value = $input.val()
	$form.find('[data-template]').removeClass('show')
	$form.find('[data-template="'+value+'"]').addClass('show')

fillDateSelects = () ->
	$('.date.selects').each (i, selects) ->
		$monthOptions = $(selects).find('.options.months')
		$null = $monthOptions.find('.checkbox.null')
		for i in [0...12]
			month = moment.months(i)
			days = moment(i+1, 'M').daysInMonth()
			object = {name: month, slug: month}
			$checkbox = addCheckbox($monthOptions, object, [])
			$checkbox.attr('data-days', days)

		$dayOptions = $(selects).find('.options.days')
		$null = $dayOptions.find('.checkbox.null')
		for i in [1..31]
			object = {name: i, slug: i}
			$checkbox = addCheckbox($dayOptions, object, [])

		$yearOptions = $(selects).find('.options.years')
		$null = $yearOptions.find('.checkbox.null')
		for i in [moment().year()...1899]
			object = {name: i, slug: i}
			$checkbox = addCheckbox($yearOptions, object, [])