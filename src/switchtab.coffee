MAX_HEIGHT = 450

# event handler for selecting a tab
selectTab = (event) ->
  event.preventDefault()
  # extract the window and tab IDs from href
  match = /(\d+)#(\d+)/.exec $(event.currentTarget).attr('href')
  console.log "Switching to tab #{match[1]} in window #{match[2]}"
  # close the popup window now that we're done with it
  window.close()
  # first focus on the containing window
  chrome.windows.update parseInt(match[1]), focused: true
  # then select the tab itself
  chrome.tabs.update parseInt(match[2]), active: true

highlightTab = (event) ->
  doHighlight $(event.currentTarget)

# make this tab the active tab if it exists
doHighlight = (tab) ->
  if tab[0]?
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
  <a class='tab' href='#{tab.windowId}##{tab.id}' data-window='#{tab.windowId}' data-tab='#{tab.id}'>
    <img class='favicon' src='#{tab.favIconUrl}' />
    <span class='details'>
      <div class='title'>#{tab.title}</div>
      <div class='url title'>#{tab.url}</div>
    </span>
  </a>
  """

# update label after changing tabs -- reset count, colorize
updateLabel = (resize) ->
  $('#count').text(size = $('.tab').size()).css 'background-color', 
    switch size
      when 0 then 'firebrick'
      when 1 then 'orange'
      else '#999'
  # attempt to resize the window based on contents. doesn't work very well in the popup window.
  $('#switchtab').height(Math.min(50 + $('.tab').height() * size, MAX_HEIGHT)) if resize
  doHighlight $('.tab').first()

# filter tabs using ignore-case regex of search term against tab title and URL.
filterTabs = (tabs, query='') ->
  # replace spaces in query with regex to match anything -- fuzzy compare!
  regex = new RegExp(query.replace(/\s/g, '.*'), 'i')
  list = $('#tabs').html('')
  list.append tab for key, tab of tabs when regex.test(tab.find('.title').text())
  updateLabel(true)

resetFilter = (tabs) ->
  $('#search').val('').focus()
  filterTabs(tabs)


chrome.tabs.query {}, (result) ->
  # build a hash of tab HTML elements so we don't have to create new ones all the time
  tabs = {}
  for tab in result
    tabs['' + tab.id] = $(template tab)

  # for starters, put all tabs in the list and highlight the first
  filterTabs(tabs)

  # register events on the body so they're always in play
  $('body')
    .on('click', '.tab', selectTab)
    .on('click', '.close', closeTab)
    .on('mouseover', '.tab', highlightTab)

  $('#search').keyup (event) ->
    switch event.which
      # enter - click active tab or reset if 0 results
      when 13 
        active = $('.tab.active')
        if active.size() > 0 then active.click() else resetFilter(tabs)
      # up - previous tab
      when 38 then doHighlight $('.tab.active').prev()
      # down - next tab
      when 40 then doHighlight $('.tab.active').next()
      # otherwise update filter
      else filterTabs tabs, @value

  # click on counter to clear filter
  $('#count').click -> resetFilter(tabs)
