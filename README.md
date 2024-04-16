# canvas-getter
## a recent-file downloader for Canvas LMS.
### imagine... your homework comes to you. automatically.

No more running after canvas files.

Nor keeping track of those pesky stupid canvas notifications.

*canvas-getter* automatically checks your classes and downloads the newest files using Canvas' official REST API. 

Now your homework shall be delivered automagically
~~will you choose to do it?~~

## Setup / Install
1. Windows:
   1. unzip zip file from releases
   2. set up `.config`
   3. rename template file `.config.jsonc`
   4. grab an api key off your Canvas settings `schoolname.instructure.com/profile/settings`
   5. replace config values the relevant info, including your classes' classids and the paths you want to save your new files to.
   6. open any cli and run the binary; it should provide some output of success/errors/downloads

autorun doesn't give feedback when downloading filesatm; run canvas-getter.exe or canvas-getter-linux in cli to see downloads & feedback in output. 
### lastly, pls dont publish your api key on the internet and pls and don't commit your real config file

## Building
bundle main.luau with darklua with provided config; then compile to binary with `lune build`

## Contributions
Are very welcome; please submit a PR and/or issue for feature requests/bugs/improvements/etc.!

##

*Made with love in Luau + Lune*