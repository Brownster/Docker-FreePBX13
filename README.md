# Docker-FreePBX13
Docker | Freepbx 13

This is a Docker file to build a Asterisk 13.1 and FreePBX 13 container, with XML for unraid 6 installs.

Not had chance to try this out yet but should be pretty close to building, will be a few weeks before i get chance to do anything else with this.


sudo docker run --name freepbx \
-v /place/to/put/backup:/etc/freepbxbackup \
--mount source=/mnt/user/appdata/freepbx/etc/asterisk,target=/etc/asterisk \
--mount source=/mnt/user/appdata/freepbx/etc/apache2,/etc/apache2 \
--mount source=/mnt/user/appdata/freepbx/var/www,/var/www/ \
--mount source=/mnt/user/appdata/freepbx/var/lib/mysql,/var/lib/mysql \
--mount source=/mnt/user/appdata/freepbx/var/lib/mysql/var/spool/asterisk,/var/spool/asterisk \
--mount source=/mnt/user/appdata/freepbx/var/lib/mysql/var/lib/asterisk,/var/lib/asterisk \
-net=host -d -t brownster/freepbx12021
