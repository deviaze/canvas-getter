# canvas-getter
## a recent-file downloader for Canvas LMS.
### imagine... your homework comes to you. automatically.

No more running after canvas files.

Nor keeping track of those pesky stupid canvas notifications.

*canvas-getter* automatically checks your classes and downloads the newest files using Canvas' official REST API. 

Now your homework shall be delivered automagically
~~will you choose to do it?~~

## Setup / Install
1. clone the repo
   > git clone https://github.com/deviaze/canvas-getter
2. set up `.config`
   1. copy the template file into a new file `.config.jsonc`
   2. grab an api key off your Canvas settings `schoolname.instructure.com/profile/settings`
   3. replace config values the relevant info, including your classes' classids and the paths you want to save your new files to.
3. add `autorun.exe` to startup programs or run `main.luau`/`main.exe` as/when needed. 
### lastly, pls dont publish your api key on the internet and pls and don't commit your real config file

## Building
wip

## Contributions
Are very welcome; please submit a PR and/or issue for feature requests/bugs/improvements/etc.!

##

*Made with love in Luau + Lune :p*