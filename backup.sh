#!/bin/bash
set -xeuo pipefail
trap '! test -x hooks/error.sh || ./hooks/error.sh' ERR
! test -x hooks/pre.sh || ./hooks/pre.sh
chmod 0600 "$SSH_KEY"
curl -sSf -d "email=$USERNAME" -d "password=$PASSWORD" -c cookies.txt -b cookies.txt https://fruux.com/account/processlogin/

curl -sSf -c cookies.txt -b cookies.txt -o fruux-hemma-calender-backup.ics https://fruux.com/calendars/export/a3298277798/d7e4d929-7399-4e87-a797-2d27e7710c12/
head -n1 fruux-hemma-calender-backup.ics | grep -q '^BEGIN:VCALENDAR'
tail -n1 fruux-hemma-calender-backup.ics | grep -q 'END:VCALENDAR[[:cntrl:]]$'

curl -sSf -c cookies.txt -b cookies.txt -o fruux-addressbook.vcf https://fruux.com/addressbooks/export/a3298277798/513c2f5a-ee8d-4071-aa22-293a7441ef43/
head -n1 fruux-addressbook.vcf | grep -q '^BEGIN:VCARD'
tail -n1 fruux-addressbook.vcf | grep -q 'END:VCARD[[:cntrl:]]$'
scp -i "$SSH_KEY" -o UserKnownHostsFile=/srv/known_hosts fruux-hemma-calender-backup.ics fruux-addressbook.vcf "$SCP_URL"
! test -x hooks/post.sh || ./hooks/post.sh
