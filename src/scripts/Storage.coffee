# Manipulate Chrome local and synced cloud storage.
#
#
# Class interfacing with Chrome storage API.
# Save and retreive data locally and to cloud.
#
class Storage
	
	constructor: ()->

	# Get key/value-pairs from local or cloud storage.
	#
	# @param [Mixed] String, array of strings, or object containing keys for the data to be retreived from storage.
	# @param [String] The storage area, where from the data will retreived. Can be 'cloud' or 'local', defaults to 'cloud'.
	# @param [boolean] The callback function returning the data when operation is complete. 
	#
	# @return [Object] Object containing found key/value-pairs. If no matching keys are found, empty object will be returned.
	#
	get: (key, area = 'cloud', callback = null)->

		console.log "Storage: I'm trying to get #{area} data..."

		getComplete = (result)->
			console.log "Storage: Ok, got #{area} data ->", result

		if not callback?  # if callback is undefined or null
			callback = getComplete

		if area is 'local'
			chrome.storage.local.get(key, callback)
		else
			chrome.storage.sync.get(key, callback)

	# Set key/value-pairs to local or cloud storage.
	#
	# @param [Object] Object containing key/value-pairs to be saved.
	# @param [String] The storage area, where from the data will be saved. Can be 'cloud' or 'local', defaults to 'cloud'.
	#
	set: (items, area = 'cloud')->

		console.log "Storage: I'm trying to save #{area} data..."

		setComplete = ()->
			console.log "Storage: Ok, saved #{area} data."

		if area is 'local'
			chrome.storage.local.set(items, setComplete)
		else
			chrome.storage.sync.set(items, setComplete)

	# Remove key/value-pairs to local or cloud storage.
	#
	# @param [Mixed] String, array of strings, or object containing keys containing key/value-pairs to be removed.
	# @param [String] The storage area, where from the data will be removed. Can be 'cloud' or 'local', defaults to 'cloud'.
	#
	remove: (items, area = 'cloud')->

		console.log "Storage: I'm trying to remove data from #{area} storage..."

		removeComplete = ()->
			console.log "Storage: Ok, removed data from #{area} storage."

		if area is 'local'
			chrome.storage.local.remove(items, removeComplete)
		else
			chrome.storage.sync.remove(items, removeComplete)

	# Delete all key/value-pairs from local or cloud storage 
	#
	# @param [String] The storage area, where from the data will be deleted. Can be 'cloud' or 'local', defaults to 'cloud'.
	#
	clear: (area = 'cloud')->

		console.log "Storage: I'm trying to delete all #{area} data..."

		clearComplete = ()->
			console.log "Storage: Ok, all #{area} data deleted."

		if area is 'local'
			chrome.storage.local.clear(clearComplete)
		else
			chrome.storage.sync.clear(clearComplete)

	# Shorthand for getting visibility -setting (are elements set visible or hidden?)
	#
	# @param [boolean] The callback function returning the data when operation is complete. 
	#
	getVisible: (callback)->
		data = @get('settingVisible', 'local', callback)

	# Shorthand for saving visibility -setting (are elements set visible or hidden?)
	#
	# @param [boolean] New value visibility -setting should be saved to.
	#
	setVisible: (newValue = true)->

		data =
			settingVisible: newValue

		@set(data, 'local')

	# Shorthand for getting view -setting (what data is show in the topmost list?)
	#
	# @param [boolean] The callback function returning the data when operation is complete. 
	#
	getView: (callback)->
		data = @get('settingView', 'cloud', callback)

	# Shorthand for saving view -setting (what data is show in the topmost list?)
	#
	# @param [boolean] New value visibility -setting should be saved to.
	#
	setView: (newValue = 'topSites')->

		data =
			settingView: newValue

		@set(data, 'cloud')

