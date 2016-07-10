# Used to retrieve data from async chrome API
#
class DataGetter

	@api
	@limit
	@dataType

	# Status of the operation.
	# Can be empty, loading or ready
	#	
	@status = 'empty'

	# Retrieved data is stored in this variable
	#
	@data = null

	# Construct new datablock
	#
	# @param [api] The chrome API function to be executed to get the data. E.g. chrome.topSites.get
	# @param [String] The structure type of this data. Can be topSites, latestBookmarks, recentHistory, otherDevices or recentlyClosed
	#
	constructor: (api, dataType = 'topSites', limit = 15)->
		@api = api
		@limit = limit
		@dataType = dataType

	# Get the data from chrome API
	#
	fetch: (api)->
		@status = 'loading'
		console.log "DataGetter: I'm calling to chrome API about #{@dataType}..."

		root = @ # Reference the class so we can access it in getter-function

		getter = (result)->

			if root.dataType is 'otherDevices' or root.dataType is 'recentlyClosed' # If we are getting tabs, we need to flatten the object first
				data = root.flatten(result)
			else if root.dataType is 'recentHistory'
				data = root.unique(result, 'url', 'title')
			else
				data = result

			root.data = data.slice(0, root.limit) # Limit the amount of data stored
			root.status = 'ready'
			root.done()

			console.log "DataGetter: Ok, got #{root.dataType} ->", root.data

		if @dataType is 'latestBookmarks' # If we are getting bookmarks, use limit here also
			
			@api(@limit, getter)

		else if @dataType is 'recentHistory' # If we are getting history, special call is needed
			
			params =
				'text': ''
				'maxResults': @limit * 2

			@api(params, getter)

		else
			
			@api(getter) # Call the api referenced in constructor

	# The callback evoked when operation status changes to 'ready'
	#
	done: ()->

	# Flatten multidimensional 'otherDevices' and 'tabs'-array (recentlyClosed)
	#
	# @param [array] The multidimensional array to be flattened
	#
	flatten: (source)->
		root = @
		result = []

		# Adds item to array to be returned
		addToResult = (title, url, result)->
			if url.indexOf('chrome://') is -1 # Exclude system urls
				result.push({ 
					'title': title
					'url': url 
					})

		if root.dataType is 'otherDevices'

			for item, i in source

				result.push({ 'heading': item.deviceName }) # Add the device as heading

				for tab in item.sessions[0].window.tabs
					addToResult tab.title, tab.url, result  # Add tabs from this session

		else if root.dataType is 'recentlyClosed'

			for item, i in source

				if item.window? # There are two kinds of objects in recentlyClosed: full sessions with multiple tabs and wiondows with single tab
					for tab in item.window.tabs # Handle multiple tabs
						addToResult tab.title, tab.url, result  # Add tabs from this session
				else # Handle single tab
					addToResult item.tab.title, item.tab.url, result

		return result

	# Remove duplicate urls and empty titles from history array (array of objects).
	#
	# @param [array] The array to be modified
	# @param [string] The name of the property which is compared to determine uniqueness
	# @param [string] Optional. The name of the property which is compared to determine if this item shouldn't be included.
	#
	# @return [array] Array with all 'undesirables' removed.
	#
	unique: (source)->

		walker = (mapItem) ->
			return mapItem['url']

		filter = (item, pos, array) ->
			return array.map(walker).indexOf(item['url']) == pos and item['title'] != ''

		source.filter filter