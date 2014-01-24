SwitchTab
=========
A simple Chrome extension for switching between open tabs across all windows with minimal effort.

Designed with Sublime Text 2 and you in mind.

## Installation
####[SwitchTab is available for free on the Chrome Web Store!](https://chrome.google.com/webstore/detail/switchtab/cifkiaojilfjmhbhlnhencpmhgddcekn?hl=en)

But if you want to go crazy, you can build it yourself from the source using [NodeJS](http://nodejs.org) and [Grunt](http://gruntjs.com):

1. In a terminal window:
  1. `git clone https://github.com/giladgray/chrome-switchtab.git` to download this repository to your machine
  2. `npm install && bower install` to install dependencies
  3. `grunt build` to compile the source code
2. In Chrome: 
  1. Navigate to `Menu > Tools > Extensions`
  2. Check `Developer Mode` in the upper right corner
  3. Click `Load unpacked extension...` button
  4. Select the `chrome-switchtab` repository folder you just cloned
3. Profit

## Development
1. `npm install && bower install` to install dependencies
2. `grunt build` or simply `grunt` to compile all sources files (they'll end up in the `dist/` folder)
3. `grunt watch` to watch files and re-compile on change
