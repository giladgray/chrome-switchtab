# event handler for selecting a tab
selectTab = (event) ->
  event.preventDefault()
  match = /(\d+)#(\d+)/.exec($(event.currentTarget).attr('href'))
  console.log 'Switching to tab ' + match[1] + 'in window ' + match[2]
  chrome.windows.update parseInt(match[1]),
    focused: true

  chrome.tabs.update parseInt(match[2]),
    active: true

highlightTab = (event) ->
  doHighlight $(event.currentTarget)

doHighlight = (tab) ->
  $('.tab.active').removeClass 'active'
  tab.addClass 'active'


# event handler for closing tab
closeTab = (event) ->
  event.preventDefault()
  match = /(\d+)#(\d+)/.exec($(event.currentTarget).parent().attr('href'))
  chrome.tabs.remove parseInt(match[2])

# HTML tab template
template = (tab) ->
  """
  <a class='tab' href='#{tab.windowId}##{tab.id}'>
    <img class='favicon' src='#{tab.favIconUrl}' />
    <span class='details'>
      <div class='title'>#{tab.title}</div>
      <div class='url title'>#{tab.url}</div>
    </span>
  </a>
  """

# hash of jQuery tab objects
tabs = {}

chrome.tabs.query {}, (result) ->
  # build a hash of tab HTML elements so we don't have to create new ones all the time
  for tab in result
    tabs['' + tab.id] = $(template(tab))

  # for starters, put all tabs in the list
  body = $('#tabs').html('')
  body.append tab for key, tab of tabs
  doHighlight $('.tab').first()

  $('body')
    .on('click', '.tab', selectTab)
    .on('click', '.close', closeTab)
    .on('mouseover', '.tab', highlightTab)

  $('#search').keyup (event) ->
    console.log event.which
    # pressing enter goes to first tab
    switch event.which
      when 13 # enter
        $('.tab.active').click()
        return
      when 40 # down
        doHighlight $('.tab.active').next()
      when 38 # up
        doHighlight $('.tab.active').prev()
      else

        # filter tabs using ignore-case regex of search term against tab title.
        # replace spaces in query with regex to match anything -- fuzzy compare!
        regex = new RegExp($('#search').val().replace(/\s/g, '.*'), 'i')
        console.log 'searching for ' + regex + '...'
        list = $('#tabs').text('')
        list.append tab for key, tab of tabs when regex.test(tab.find('.title').text())
        doHighlight $('.tab').first()

