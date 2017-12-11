# Docker-FreePBX13
Docker | Freepbx 13

This is a Docker file to build a Asterisk 13.1 and FreePBX 13 container, with XML for unraid 6 installs.

Not had chance to try this out yet but should be pretty close to building, will be a few weeks before i get chance to do anything else with this.

I HAVE ONE ALREADY BUILT BASED ON FREEPBX 12 JUST RUN SOMETHING LIKE:

sudo docker run --name freepbx \
-v /mnt/user/appdata/freepbx/backup:/freepbx/backup \
-v /mnt/user/appdata/freepbx/etc/asterisk:target=/etc/asterisk \
-v /mnt/user/appdata/freepbx/etc/apache2:/etc/apache2 \
-v /mnt/user/appdata/freepbx/var/www:/var/www/ \
-v /mnt/user/appdata/freepbx/var/lib/mysql:/var/lib/mysql \
-v /mnt/user/appdata/freepbx/var/lib/mysql/var/spool/asterisk:/var/spool/asterisk \
-v /mnt/user/appdata/freepbx/var/lib/mysql/var/lib/asterisk:/var/lib/asterisk \
-net=none --network homenet -d -t brownster/freepbx12021

see this post for setting up homenet docker network saves messing with port forwarding etc :
https://forums.lime-technology.com/topic/54882-630-how-to-setup-dockers-without-sharing-unraid-ip-address/
