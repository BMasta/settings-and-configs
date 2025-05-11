# Hack firefox into changing keybindings
Based off of this post: https://superuser.com/questions/1271147/change-key-bindings-keyboard-shortcuts-in-firefox-57
* Navigate to the firefox directory.
* Copy autoconfig.js to `<firefox_dir>/defaults/pref/autoconfig.js`.
* Copy firefox.cfg to `<firefox_dir>/firefox.cfg`.
* In the firefox window, go to about:support and run "Clear startup cache".

There are two ways to find keys/commands/elements:
1. Go to "view-source:chrome://browser/content/browser.xhtml"
2. (Recommended) Go to "about:config". \
   Set devtools.chrome.enabled and devtools.debugger.remote-enabled to true. \
   Launch browser toolbox: Menu -> More Tools -> Browser Toolbox.

Then search for mainKeyset, that's where all the keybindings are. \
Letter keys are just letters. Special keys will have the format `VK_*`. \
Modifiers are accel (ctrl), alt, shift.
