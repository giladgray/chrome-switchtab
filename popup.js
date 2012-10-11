// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var tabs = {}
chrome.tabs.query({}, function(result) {
	console.log(result);
	// build a hash of tab HTML elements so we don't have to create new ones all the time
	for (var i =  0; i < result.length; i++) {
		var tab = result[i];
		tabs['' + tab.id] = $("<a>").addClass('tab').attr('href', tab.windowId + "#" + tab.id)
			.append($('<img>').addClass('favicon').attr('src', tab.favIconUrl))
			.append($('<span>').addClass('details')
				.append($('<div>').addClass('title').text(tab.title))
				.append($('<div>').addClass('url title').text(tab.url)))
			.append($('<span>').addClass('close').html('&times;'));
	};

	// for starters, put all tabs in the list
	body = $('#tabs').html('');
	$.each(tabs, function(index, item) { body.append(item); });
	$('.tab').click(selectTab);

	$('#search').keyup(function(event) {
		// pressing enter goes to first tab
		if(event.which == 13) {
			$('.tab').first().click();
			return;
		}

		// filter tabs using ignore-case regex of search term against tab title
		regex = new RegExp($('#search').val(), 'i')
		list = $('#tabs').text('');
		console.log("searching for " + regex + '...');
		$.each(tabs, function(index, item) {
			title = item.find('.title').text();
			// TODO: also check against URL?
			if(regex.test(title)) {
				list.append(item);
			}
		});
		// configure event handlers for all these new tabs
		list.find('.tab').click(selectTab);
		list.find('.close').click(closeTab);
	});
});

function selectTab(event) {
	event.preventDefault();
	match = /(\d+)#(\d+)/.exec($(event.currentTarget).attr('href'));
	console.log("Switching to tab " + match[1] + "in window " + match[2]);
	chrome.windows.update(parseInt(match[1]), {'focused': true});
	chrome.tabs.update(parseInt(match[2]), {'active': true});
}

function closeTab(event) {
	event.preventDefault();
	match = /(\d+)#(\d+)/.exec($(event.currentTarget).parent().attr('href'));
	chrome.tabs.remove(parseInt(match[2]));
}