// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var tabs = {}
chrome.tabs.query({}, function(result) {
  tabs = result;
  console.log(tabs);
  for (var i =  0; i < tabs.length; i++) {
    tab = tabs[i];
    element = $("<div>").addClass('tab').append($('<img>').addClass('favicon').attr('src', tab.favIconUrl)).append($('<span>').addClass('title').text(tab.title));
    $('body').append(element);
  };
});