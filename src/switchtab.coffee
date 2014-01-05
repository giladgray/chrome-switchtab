MAX_HEIGHT = localStorage['switchtab_height'] or 400
ANIM_TIME = 1000 * .3

$tabs = undefined
tabCount = 0

$.fn.takeClass = (targetClass, scope='') ->
  $("#{scope} .#{targetClass}").removeClass targetClass
  @addClass targetClass

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
  doHighlight($(event.currentTarget))

# make this tab the active tab if it exists
doHighlight = (tab) ->
  # select by index if passed a number
  if typeof tab is 'number'
    tab = $ $('.tab.match')[tab]
  tab.takeClass 'active' if tab[0]?

# event handler for closing tab
closeTab = (event) ->
  event.preventDefault()
  match = /(\d+)#(\d+)/.exec($(event.currentTarget).parent().attr('href'))
  chrome.tabs.remove parseInt(match[2])

# HTML tab template
template = (tab) ->
  """
  <a class='tab' href='#{tab.windowId}##{tab.id}' data-window='#{tab.windowId}' data-tab='#{tab.id}'>
    <img class='favicon' src='#{tab.favIconUrl}'>
    <span class='details'>
      <div class='title'>#{tab.title}</div>
      <div class='url title'>#{tab.url}</div>
    </span>
  </a>
  """

# update label after changing tabs -- reset count, colorize
updateLabel = (resize) ->
  $('#count').text(size = $('.tab.match').size()).css 'background-color',
    switch size
      when 0 then 'firebrick'
      when 1 then 'orange'
      else '#999'
  # resize the window based on contents. small delay for CSS transitions to finish
  if resize then setTimeout ->
    $('#switchtab').height(Math.min($tabs.height() + $tabs.offset().top, MAX_HEIGHT))
  , ANIM_TIME

# filter tabs using ignore-case regex of search term against tab title and URL.
filterTabs = (query='') ->
  # replace spaces in query with regex to match anything -- fuzzy compare!
  regex = new RegExp(query.replace(/\s/g, '.*'), 'i')
  # filter tabs by adding a "match" class if the regex passes test
  # this lets use smoothly animate tabs
  $tabs.find('.tab').each (i) ->
    $el = $(@)
    if regex.test $el.find('.title').text()
      $el.addClass('match')
    else $el.removeClass('match')
  # select first matched tab
  $tabs.find('.match:first').takeClass 'active'

  updateLabel(false)

resetFilter = () ->
  $('#search').val('').focus()
  filterTabs()


chrome.tabs.query {}, (result) ->
  # cache jQuery selector for future use
  $tabs = $('#tabs')
  $window = null
  thisWindow = -1
  for tab in result
    if tab.windowId isnt thisWindow
      # make a new window element for tabs
      $window = $('<div>').addClass('window')
      $tabs.append $window
      thisWindow = tab.windowId
    # add tab to current window
    $window.append template tab
  # tab and window counts
  tabCount = $('.tab').size()
  $tabs.append $('<div>').addClass('footer')
    .text("#{tabCount} tab#{if tabCount > 0 then 's' else ''} across #{$('.window').size()} windows")

  # add borders when top/bottom of tabs list aren't visible
  $tabs.scroll ->
    if @scrollTop > 5 then $tabs.addClass('scroll-top')
    else $tabs.removeClass('scroll-top')

    if @scrollHeight - @scrollTop - @clientHeight > 30
      $tabs.addClass('scroll-bottom')
    else $tabs.removeClass('scroll-bottom')

  # for starters, put all tabs in the list and highlight the first
  filterTabs()

  # register events on the body so they're always in play
  $('body')
    .on('click', '.tab', selectTab)
    .on('click', '.close', closeTab)
    .on('mouseover', '.tab', highlightTab)

  # some keyevents
  $('#search').keyup (event) ->
    switch event.which
      # enter - click active tab or reset if 0 results
      when 13
        active = $('.tab.active')
        if active.size() > 0 then active.click() else resetFilter(tabs)
      # up - previous tab
      when 38 then doHighlight $('.tab.match').index($('.tab.active')) - 1
      # down - next tab
      when 40 then doHighlight $('.tab.match').index($('.tab.active')) + 1
      else filterTabs @value

  # click on counter to clear filter
  $('#count').click -> resetFilter(tabs)
