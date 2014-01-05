window.addEventListener 'keydown', (event) ->
	# TODO: open popup when hotkey is pressed
	if event.altKey and event.which is 84
		width = localStorage['switchtab_width'] or 420
		height = localStorage['switchtab_height'] or 400
		left = (screen.width - height) / 2
		url  = chrome.extension.getURL('popup.html')
		popup = window.open url, 'SwitchTab',
			"height=#{height},width=#{width},left=#{left},location=0,menubar=0,status=0,titlebar=0,toolbar=0"
