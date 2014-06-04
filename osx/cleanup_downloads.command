name=cleanup_downloads

nice -n 11 rm -r -d -P ~/tmp/* 2> /dev/null &
nice -n 12 brew cleanup --force -s 2> /dev/null &
nice -n 13 npm cache clean 2> /dev/null &
nice -n 14 rm -r -d ~/.gem/specs/* 2>/dev/null &
nice -n 15 rm -r -d ~/.m2/repository/* 2>/dev/null &
nice -n 16 rm -r -d ~/.gradle/* 2>/dev/null &
nice -n 17 rm -r -d ~/.groovy/grapes/* 2>/dev/null &
nice -n 18 find ~/Downloads -type f -atime 1 -exec rm -r -d -P \{\} \; 2>/dev/null &
nice -n 19 find /var/tmp -type f -atime 1 -exec rm -r -d -P \{\} \; 2>/dev/null &
nice -n 20 find /var/folders -type f -atime 1 -exec rm -r -d -P \{\} \; 2>/dev/null &
