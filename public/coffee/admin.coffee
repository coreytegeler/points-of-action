$ ->
	$body = $('body')
	$main = $('main')

$ ->
	$body = $('body')
	$main = $('main')

	initAdmin = () ->
		getData()
		$body.on 'click',  'form .add', openQuicky
		$body.on 'click',  'form .images .edit', openQuicky
		$body.on 'click',  '.quicky .close', closeQuicky
		$body.on 'submit', '.quicky form', quickySave
		$body.on 'click',  'a.delete', deleteObject
		$body.on 'click',  '.button.clear', () ->
			$('.images input:text').val('[]')
			$('.images .image:not(.empty)').remove()
		
		$sortable = $('.sortable')
		sortable = $( '.sortable ul' ).sortable
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

		$('textarea').each () ->
			editor = new MediumEditor(this, {
				buttons: ['italic', 'underline', 'anchor', 'superscript'],
				placeholder: false,
				imageDragging: false,
				targetBlank: true,
				paste: {
	        forcePlainText: true,
	        cleanPastedHTML: true,
	        cleanReplacements: [],
	        cleanAttrs: ['class', 'style', 'dir'],
	        cleanTags: ['meta'],
	        unwrapTags: ['span', 'div', 'h1', 'h2', 'h3', 'h4', 'label']
		    }
			})
			$(editor.elements).each () ->
				$(this).addClass('editable')


	getData = () ->
		if($('form .images').length)
			$('form .images .image').each (i, imageWrap) ->
				if($(imageWrap).is('.sample'))
					addQuicky('image')
				else
					id = $(imageWrap).attr('data-id')
					if(id)
						addQuicky('image', id)

		$('form .populate').each (i, container) ->
			modelType = $(container).data('model')
			containerType = $(container).data('type')
			label = $(container).prev('label').text()
			addQuicky(modelType, null, label)
			if(modelType == 'historicUse')
				modelType = 'use'
			$.ajax
				url: '/api/?type='+modelType+'&format=json',
				error:  (jqXHR, status, error) ->
					console.log jqXHR, status, error
					return
				success: (objects, status, jqXHR) ->
					if(!objects)
						return
					switch containerType
						when 'checkboxes'
							$(objects).each (i, object) ->
								checked = $(container).data('checked')
								addCheckbox(container, object, checked)
					$(container).addClass('loaded')
					return
			return
		return

	addCheckbox = (container, object, checked) ->
		$clone = $(container).find('.empty').clone().removeClass('empty')
		$clone.find('input').attr('checked', false)
		$label = $clone.find('label')
		$input = $clone.find('input')
		if !object
			return
		valueObject = {name: object.name, slug: object.slug, id: object._id}
		if(object.color)
			valueObject['color'] = object.color
		if(object.buildings)
			valueObject['buildings'] = object.buildings
		value = JSON.stringify(valueObject)
		model = $(container).data('model')
		$input.attr('value', value).attr('id', model+'-'+object.slug)
		$label.text(object.name).attr('for', model+'-'+object.slug)
		if checked
			if $.isArray(checked)
				for checkedValue in checked
					try
						checkedObj = JSON.parse(checkedValue)
					catch
			    	checkedObj = checkedValue
					if valueObject.id == checkedObj.id
						$input.attr('checked', true)
			else if (valueObject.id == checked || valueObject.id == checked.id) 
				$input.attr('checked', true)
		$clone
			.attr('data-slug', object.slug)
			.prependTo(container)
		$(container).addClass('loaded')
		return

	# openSelect = (event) ->
	# 	$select = $(event.target).parents('.select')
	# 	datetype = $select.attr('data-datetype')
	# 	$options = $select.find('.options')
	# 	$select.siblings('.select').find('.options').removeClass('open')
	# 	$options.toggleClass('open')
	# 	return

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

	addQuicky = (type, id, label) ->
		if($('.quicky[data-id="' + id + '"]').length)
			return
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
				$('.quickies').append(html)
		return

	openQuicky = () ->
		$button = $(this)
		id = $button.data('id')
		type = $button.data('model')
		if(!id)
			$quicky = $('.quicky.create[data-model="'+type+'"]')
		else
			$quicky = $('.quicky.edit[data-id="'+id+'"]')
		$quicky.addClass('open')
		$quicky.find('input[name="name"]').focus()
		return

	closeQuicky = (quicky) ->
		if(quicky.length)
			$quicky = $(quicky)
		else
			$quicky = $(this).parents('.quicky')
		if(!$quicky.is('[data-model="image"]'))
			$quicky.find('input:not([type="submit"])').each (i, input) ->
				$(input).val('')
		$quicky.removeClass('open')
		$quicky.removeClass('saving')
		return

	quickySave = (event) ->
		event.stopPropagation()
		event.preventDefault()
		$form = $(this)
		$quicky = $form.parents('.quicky')
		id = $quicky.data('id')
		type = $quicky.data('model')
		data = new FormData()
		if(type == 'image' && !id.length)
			image = $form.find('input:file')[0].files[0]
			caption = $form.find('input.caption').val()
			data.append('image', image, image.name)
			data.append('caption', caption)
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
				type = $quicky.data('model')
				checkboxes = $('.checkboxes.'+type)
				if(checkboxes.length)
					addCheckbox(checkboxes, object, object._id)
				else if(type == 'image')
					addImage(object)
				$quicky.removeClass('saving')
				closeQuicky($quicky)
		return

	addImage = (object) ->
		$imagesWrapper = $('.images')
		$imagesInput = $imagesWrapper.find('input:text')
		addQuicky('image', object._id, '')
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
			newImg.src = imageObject.original;

	# updateTemplate = (event) ->
	# 	$input = $(event.target)
	# 	value = $input.val()
	# 	$('[data-template]').removeClass('show')
	# 	$('[data-template="'+value+'"]').addClass('show')

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

	initAdmin()