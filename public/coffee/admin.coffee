$ ->
	$body = $('body')
	$main = $('main')
	$mainForm = $('form.main')

	initAdmin = () ->
		# getData()
		setupForm($mainForm)
		$body.on 'submit',  'form.main', formSave
		$body.on 'click',  'form .add', addQuicky
		$body.on 'click',  'form .images .edit', addQuicky
		$body.on 'click',  '.quicky .close', closeQuicky
		$body.on 'submit', '.quicky form', saveQuicky
		$body.on 'click',  'a.delete', deleteObject
		$body.on 'click',  '.dateselect .select', openDateOptions
		$body.on 'click',  '.dateselect .checkbox label', selectDateOption

	getData = () ->
		if($('form .images').length)
			$('form .images .image').each (i, imageWrap) ->
				if($(imageWrap).is('.sample'))
					addQuicky('image')
				else
					id = $(imageWrap).attr('data-id')
					if(id)
						addQuicky('image', id)

	setupForm = (form) ->
		populateCheckboxes(form)
		setupSortable(form)
		setupEditor(form)
		setupDateSelector(form)

	populateCheckboxes = (form) ->
		$(form).find('.populate:not(.populated)').each (i, container) ->
			model = $(container).data('model')
			type = $(container).data('type')
			checked = $(container).data('checked')
			label = $(container).prev('label').text()
			# addQuicky(model, null, label)
			$(this).addClass('populated')
			if(model == 'historicUse')
				model = 'use'
			$.ajax
				url: '/api/json/?type='+model,
				error:  (jqXHR, status, error) ->
					console.log jqXHR, status, error
					return
				success: (objects, status, jqXHR) ->
					if(!objects)
						return
					listId = model+'-checkboxes'
					$(objects).each (i, object) ->
						addCheckbox(container, object, checked)
					filterList = new List listId,
						valueNames: ['checkbox']
					$(container).addClass('loaded')
					return
			return
		return

	addCheckbox = (container, object, checked) ->
		if checked && !$.isArray(checked)
			checked = [checked]
		$checkbox = $(container).find('.empty').clone().removeClass('empty')
		$checkbox.find('input').attr('checked', false)
		$options = $(container).find('.options')
		$label = $checkbox.find('label')
		$input = $checkbox.find('input')
		if !object
			return
		if typeof object == 'object'
			if(object._id)
				id = object._id
			else 
				id = object.id
			valueObject = {name: object.name, slug: object.slug, id: id}
			slug = valueObject.slug
			value = JSON.stringify(valueObject)
		else
			value = {id: object}
			slug = value
		model = $(container).data('model')
		$input.attr('value', value).attr('id', model+'-'+object.slug)
		$label.text(object.name).attr('for', model+'-'+object.slug)
		if checked
			for checkedVal in checked
				try
					checkedVal = JSON.parse(checkedVal).id
				if checkedVal && valueObject.id == checkedVal.id
					$input.attr('checked', true)
		$checkbox.attr('data-slug', slug)
		$options.prepend($checkbox)
		$(container).addClass('loaded')
		return $checkbox

	formSave = (event) ->
		$(window.editors).each () ->
			editor = this
			name = editor.container.dataset.name
			$inputHTML = $('input[name="'+name+'HTML"]')
			$inputJSON = $('input[name="'+name+'JSON"]')
			if(json = editor.getContents())
				json = JSON.stringify(json)
				$inputJSON.val(json)
			if(html = editor.root.innerHTML)
				$inputHTML.val(html)
			# event.preventDefault()
			
	# updateSelectValue = (event) ->
	# 	option = event.target 
	# 	value = option.value
	# 	console.log(value)
	# 	$select = $(option).parents('.select')
	# 	$options = $select.find('.options')
	# 	$display = $select.find('.display')
	# 	$display.html(value)
	# 	$options.removeClass('open')
	# 	return


	addQuicky = () ->
		$button = $(this)
		id = $button.data('id')
		type = $button.data('type')
		if(!id && $('.quicky.create[data-type="'+type+'"]').length)
			openQuicky($('.quicky.create[data-type="'+type+'"]'))
		else if($('.quicky.edit[data-id="'+id+'"]').length)
			openQuicky($('.quicky.edit[data-id="'+id+'"]'))
		else
			loadQuicky(type, id)

	loadQuicky = (type, id, label) ->
		if($quicky = $('.quicky[data-id="' + id + '"]').length)
			$quicky.addClass('open')
			$quicky.find('input[name="name"]').focus()
		else
			url = '/admin/'+type+'/quicky/'
			if(id)
				url += id
			$.ajax
				url: url
				error: (jqXHR, status, error) ->
					console.log jqXHR, status, error
					return
				success: (html, status, jqXHR) ->
					if(!html)
						return
					$quicky = $(html)
					$('.quickies').append($quicky)
					$form = $quicky.find('form')
					setupForm($form)
					openQuicky($quicky)

	openQuicky = (quicky) ->
		$(quicky).addClass('open')
		$(quicky).find('input[name="name"]').focus()

	closeQuicky = (quicky) ->
		if(quicky.length)
			$quicky = $(quicky)
		else
			$quicky = $(this).parents('.quicky')
		if(!$quicky.is('[data-type="image"]'))
			$quicky.find('input:not([type="submit"])').each (i, input) ->
				$(input).val('')
		$quicky.removeClass('open')
		$quicky.removeClass('saving')
		return

	saveQuicky = (event) ->
		event.preventDefault()
		$form = $(this)
		$quicky = $form.parents('.quicky')
		id = $quicky.data('id')
		model = $quicky.data('model')
		data = new FormData()
		console.log model, id
		if(model == 'images' && !id)
			image = $form.find('input:file')[0].files[0]
			console.log image
			caption = $form.find('input.caption').val()
			data.set('image', image, image.name)
			data.set('caption', caption)
			contentType = false
			processData = false
		else
	  	data = $form.serializeArray()
	  	contentType = 'application/x-www-form-urlencoded; charset=UTF-8'
	  	processData = true
		postUrl = $form.attr('action')
		if(!data)
			return
		$quicky.addClass('saving')
		$.ajax
			type: 'POST',
			data: data,
			url: postUrl,
			processData: processData,
			contentType: contentType,
			error: (jqXHR, status, error) ->
				console.log(postUrl, jqXHR, status, error)
				alert('Error, check browser console logs')
			success: (object, status, jqXHR) ->
				checkboxes = $('main .checkboxes.'+model)
				checked = {id:object._id}
				if(checkboxes.length)
					addCheckbox(checkboxes, object, checked)
				else if(model == 'images')
					addImage(object)
				$quicky.removeClass('saving')
				closeQuicky($quicky)
		return

	addImage = (object) ->
		$imagesWrapper = $('form.main').find('.images')
		$imagesInput = $imagesWrapper.find('input:text')
		imageObject = {
			id: object._id,
			original: object.original,
			medium: object.medium,
			small: object.small,
			caption: object.caption
		}
		if($imagesInput.val())
			imagesInputVal = JSON.parse($imagesInput.val())
		else
			imagesInputVal = []
		updating = false
		if(imagesInputVal.length)
			for i, thisObject of imagesInputVal
				if(thisObject.id == imageObject.id)
					imagesInputVal[i] = imageObject
					updating = true
			if(!updating)
				imagesInputVal.push(imageObject)
		else
			imagesInputVal = [imageObject]
		$imagesInput.val(JSON.stringify(imagesInputVal))
		if(!$imagesWrapper.find('.image[data-id="'+object._id+'"]').length)
			$clone = $imagesWrapper.find('.sample').clone()
			$clone.removeClass('sample')
			$clone.attr('data-id', imageObject.id)
			newImg = new Image()
			newImg.onload = () ->
				$clone.find('img').remove()
				$clone.append(this)
				$clone.find('.caption').text(imageObject.caption)
				$imagesWrapper.find('.ui-sortable').append($clone)
			newImg.src = imageObject.original

	updateTemplate = (event) ->
		$input = $(event.target)
		value = $input.val()
		$('[data-template]').removeClass('show')
		$('[data-template="'+value+'"]').addClass('show')

	deleteObject = (event) ->
		if(!confirm('Are you sure you want to delete this?'))
			return event.preventDefault();
		$quicky = $(this).parents('.quicky')
		if($quicky.length) # if is image
			id = $quicky.attr('data-id')
			$input = $('.images input:text[name="images"]')
			inputVal = JSON.parse($input.val())
			inputVal = inputVal.filter (image) ->
		    return image.id != id
			inputVal = JSON.stringify(inputVal)
			$input.val(inputVal)
			$('.image[data-id="'+id+'"]').remove()
			$quicky.remove()
			$main.removeClass('noscroll')
			return event.preventDefault()

	setupDateSelector = (form) ->
		$(form).find('.dateselect').each (i, selects) ->
			$monthOptions = $(selects).find('.checkboxes.month')
			checkedMonth = {id:$monthOptions.data('checked')}
			if checkedMonth.id
				checkedMonth.id = checkedMonth.slug
			for i in [12...0]
				month = moment.months(i-1)
				days = moment(i, 'M').daysInMonth()
				object = {name: month, slug: i, id: i}
				$checkbox = addCheckbox($monthOptions, object, checkedMonth)
				$checkbox.attr('data-days', days)

			$dayOptions = $(selects).find('.checkboxes.day')
			checkedDay = {id:$dayOptions.data('checked')}
			if checkedDay.id
				checkedDay.id = checkedDay.slug
			for i in [31...0]
				object = {name: i, slug: i, id: i}
				$checkbox = addCheckbox($dayOptions, object, checkedDay)

			$yearOptions = $(selects).find('.checkboxes.year')
			checkedYear = {id:$yearOptions.data('checked')}
			if checkedYear.id
				checkedYear.id = checkedYear.slug
			for i in [moment().year()...1899]
				object = {name: i, slug: i, id: i}
				$checkbox = addCheckbox($yearOptions, object, checkedYear)

	openDateOptions = (e) ->
		$dateselect = $(this).parents('.dateselect')
		type = this.dataset.type
		$checkboxes = $dateselect.find('.checkboxes.'+type)

		$dateselect.find('.select:not(.'+type+')').removeClass('selected')
		$dateselect.find('.checkboxes:not(.'+type+')').removeClass('open')
		$(this).toggleClass('selected')
		$checkboxes.toggleClass('open')

	selectDateOption = (e) ->
		$dateselect = $(this).parents('.dateselect')
		$checkboxes = $(this).parents('.checkboxes')
		type = $checkboxes.data('model')
		$select = $dateselect.find('.select.'+type)
		object = JSON.parse($(this).prev('input').val())
		$select.find('.display').text(object.name)
		$select.find('.input').val(object.slug)


	setupEditor = (form) ->
		window.editors = []
		toolbarOpt = [
			['bold', 'italic', 'underline'],
			['blockquote'],
			[{ 'header': 1 }, { 'header': 2 }],
			[{ 'list': 'ordered'}, { 'list': 'bullet' }],
			[{ 'script': 'sub'}, { 'script': 'super' }],
			[{ 'indent': '-1'}, { 'indent': '+1' }],
			[{ 'size': ['small', false, 'large', 'huge'] }],
			['clean']
		]   
		editorOpt =
		  modules:
		    toolbar: toolbarOpt
		  theme: 'snow'
		$(form).find('.textarea').each (i, textarea) ->
			editor = new Quill(textarea, editorOpt)
			name = textarea.dataset.name
			contents = $(form).find('input[name="'+name+'HTML"]').val()
			if(contents.length)
				editor.setContents(JSON.parse(contents));
			window.editors.push(editor)


	setupSortable = (form) ->
		$sortable = $(form).find('.sortable')
		sortable = $sortable.find('ul').sortable
			update: (e, elem) ->
				newOrder = []
				$sortableInput = $sortable.find('input')
				$(this).find('li').each () ->
					id = $(this).data('id')
					newOrder.push(id)
				if($sortable.is('.images'))
					imagesData = JSON.parse($sortableInput.val())
					newOrderClone = newOrder
					$(imagesData).each () ->
						index = newOrder.indexOf(this.id)
						newOrder[index] = this
				newOrderJson = JSON.stringify(newOrder)
				$sortable.find('input').val(newOrderJson)
		sortable.disableSelection()

	initAdmin()