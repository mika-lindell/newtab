class Toast

	constructor: (msg, iconName = null, buttonLabel = null, buttonCallback = null,  duration = 5.0)->

		container = new HTMLElement('div')
		content = new HTMLElement('span')
		body = new HTMLElement('body')

		container.addClass 'toast'
		container.addClass 'anim-toast-in'

		content.addClass 'toast-content'
		content.html msg.replace(' ', '&nbsp;')

		if iconName?
			icon = new HTMLElement('i')
			icon.addClass 'material-icons'
			icon.addClass 'left'
			icon.text iconName
			container.append icon

		container.append content

		if buttonLabel? and buttonCallback?
			button = new HTMLElement('button')
			button.addClass 'btn'
			button.addClass 'btn-link'
			button.text	buttonLabel

			button.on('click', ()->
				cleanup()
				buttonCallback()
			)

			container.append button

		body.append container

		cleanup = ()->
			if container?

				container.removeClass 'anim-toast-in'
				container.addClass 'anim-toast-out'

				setTimeout ()->
					body.removeChild container
					container = null
				, 500

		# Outro and cleanup if not hidden yet by user interaction
		if container?
			setTimeout ()->
				cleanup()
			, duration * 1000

