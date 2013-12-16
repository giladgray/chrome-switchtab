(function() {
  window.addEventListener('keydown', function(event) {
    var height, left, popup, width;
    if (event.altKey && event.which === 84) {
      width = localStorage['switchtab_width'] || 420;
      height = localStorage['switchtab_height'] || 450;
      left = (screen.width - height) / 2;
      return popup = window.open(chrome.extension.getURL('popup.html'), '_blank', "height=" + height + ",width=" + width + ",left=" + left + ",location=0,menubar=0,status=0,titlebar=0,toolbar=0");
    }
  });

}).call(this);

(function() {
  var MAX_HEIGHT, closeTab, doHighlight, filterTabs, highlightTab, resetFilter, selectTab, template, updateLabel;

  MAX_HEIGHT = 450;

  selectTab = function(event) {
    var match;
    event.preventDefault();
    match = /(\d+)#(\d+)/.exec($(event.currentTarget).attr('href'));
    console.log("Switching to tab " + match[1] + " in window " + match[2]);
    window.close();
    chrome.windows.update(parseInt(match[1]), {
      focused: true
    });
    return chrome.tabs.update(parseInt(match[2]), {
      active: true
    });
  };

  highlightTab = function(event) {
    return doHighlight($(event.currentTarget));
  };

  doHighlight = function(tab) {
    if (tab[0] != null) {
      $('.tab.active').removeClass('active');
      return tab.addClass('active');
    }
  };

  closeTab = function(event) {
    var match;
    event.preventDefault();
    match = /(\d+)#(\d+)/.exec($(event.currentTarget).parent().attr('href'));
    return chrome.tabs.remove(parseInt(match[2]));
  };

  template = function(tab) {
    return "<a class='tab' href='" + tab.windowId + "#" + tab.id + "' data-window='" + tab.windowId + "' data-tab='" + tab.id + "'>\n  <img class='favicon' src='" + tab.favIconUrl + "' />\n  <span class='details'>\n    <div class='title'>" + tab.title + "</div>\n    <div class='url title'>" + tab.url + "</div>\n  </span>\n</a>";
  };

  updateLabel = function(resize) {
    var size;
    $('#count').text(size = $('.tab').size()).css('background-color', (function() {
      switch (size) {
        case 0:
          return 'firebrick';
        case 1:
          return 'orange';
        default:
          return '#999';
      }
    })());
    if (resize) {
      $('#switchtab').height(Math.min(50 + $('.tab').height() * size, MAX_HEIGHT));
    }
    return doHighlight($('.tab').first());
  };

  filterTabs = function(tabs, query) {
    var key, list, regex, tab;
    if (query == null) {
      query = '';
    }
    regex = new RegExp(query.replace(/\s/g, '.*'), 'i');
    list = $('#tabs').html('');
    for (key in tabs) {
      tab = tabs[key];
      if (regex.test(tab.find('.title').text())) {
        list.append(tab);
      }
    }
    return updateLabel(true);
  };

  resetFilter = function(tabs) {
    $('#search').val('').focus();
    return filterTabs(tabs);
  };

  chrome.tabs.query({}, function(result) {
    var tab, tabs, _i, _len;
    tabs = {};
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      tab = result[_i];
      tabs['' + tab.id] = $(template(tab));
    }
    filterTabs(tabs);
    $('body').on('click', '.tab', selectTab).on('click', '.close', closeTab).on('mouseover', '.tab', highlightTab);
    $('#search').keyup(function(event) {
      var active;
      switch (event.which) {
        case 13:
          active = $('.tab.active');
          if (active.size() > 0) {
            return active.click();
          } else {
            return resetFilter(tabs);
          }
          break;
        case 38:
          return doHighlight($('.tab.active').prev());
        case 40:
          return doHighlight($('.tab.active').next());
        default:
          return filterTabs(tabs, this.value);
      }
    });
    return $('#count').click(function() {
      return resetFilter(tabs);
    });
  });

}).call(this);
