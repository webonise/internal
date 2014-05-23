name=cleanup_downloads

nice -n 11 rm -r -d -P ~/tmp/* &
nice -n 12 brew cleanup --force -s &
nice -n 13 npm cache clean &
nice -n 14 rm -r -d ~/.gem/specs/* &
nice -n 15 rm -r -d ~/.m2/repository/* &
nice -n 16 rm -r -d ~/.gradle/* &
nice -n 17 rm -r -d ~/.groovy/grapes/* &
nice -n 18 find ~/Downloads -type f -atime 1 -exec rm -r -d -P \{\} \; &
nice -n 19 find /var/tmp -type f -atime 1 -exec rm -r -d -P \{\} \; &
nice -n 20 find /var/folders -type f -atime 1 -exec rm -r -d -P \{\} \; &
