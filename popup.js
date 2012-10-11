// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var tabs = {}
chrome.tabs.query({}, function(result) {
  console.log(result);
  for (var i =  0; i < result.length; i++) {
    var tab = result[i];
    tabs['' + tab.id] = $("<a>").addClass('tab').attr('href', tab.windowId + "#" + tab.id)
    	.append($('<img>').addClass('favicon').attr('src', tab.favIconUrl))
    	.append($('<span>').addClass('details')
    		.append($('<div>').addClass('title').text(tab.title))
    		.append($('<div>').addClass('url title').text(tab.url)));
  };

  body = $('#tabs');
  $.each(tabs, function(index, item) { body.append(item); });
  $('.tab').click(selectTab);

  $('#search').keydown(function(event) {
    console.log("searching for " + $('#search').val());

    list = $('#tabs').text('');
    $.each(tabs, function(index, item) {
      var title = item.find('.title').text();
      var regex = new RegExp($('#search').val(), 'i')
      if(regex.test(title))
        list.append(item);
    });
    list.find('.tab').click(selectTab);
  });
});

function selectTab(event) {
  event.preventDefault();
  match = /(\d+)#(\d+)/.exec($(event.currentTarget).attr('href'));
  console.log("Switching to tab " + match[1] + "in window " + match[2]);
  chrome.windows.update(parseInt(match[1]), {'focused': true});
  chrome.tabs.update(parseInt(match[2]), {'active': true});
}