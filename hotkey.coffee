console.log "INJECTED!"
window.addEventListener 'keydown', (event) ->
	console.log event
	# TODO: open popup when hotkey is pressed
	if event.altKey and event.which is 84
		# window.open 'switchtab.html'
		console.log "HOTKEY!"
