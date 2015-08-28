#asterisk docker file for unraid 6
FROM phusion/baseimage:0.9.15
MAINTAINER marc brown <marc@22walker.co.uk> v0.0.2

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV ASTERISKUSER asterisk
ENV ASTERISKVER 13.1
ENV FREEPBXVER 13.0
ENV FREEPBXPORT 8009
ENV ASTERISK_DB_PW pass123
ENV AUTOBUILD_UNIXTIME 1418234402
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add VOLUME to allow backup of FREEPBX
VOLUME ["/etc/freepbxbackup"]

# open up ports needed  by freepbx and asterisk 5060 tcp sip reg 80 tcp web port 10000-20000 udp rtp stream  
EXPOSE 5060
EXPOSE 80
EXPOSE 8009
EXPOSE 10000-20000/udp

# Add start.sh
ADD start.sh /root/

#Install packets that are needed
# RUN apt-get update && apt-get install -y build-essential curl libgtk2.0-dev linux-headers-`uname -r` openssh-server apache2 mysql-server mysql-client bison flex php5 php5-curl php5-cli php5-mysql php-pear php-db php5-gd curl sox libncurses5-dev libssl-dev libmysqlclient-dev mpg123 libxml2-dev libnewt-dev sqlite3 libsqlite3-dev pkg-config automake libtool autoconf git subversion unixodbc-dev uuid uuid-dev libasound2-dev libogg-dev libvorbis-dev libcurl4-openssl-dev libical-dev libneon27-dev libsrtp0-dev libspandsp-dev wget sox mpg123 libwww-perl php5 php5-json libiksemel-dev openssl lamp-server^ 1>/dev/null

RUN apt-get install -y build-essential linux-headers-`uname -r` openssh-server apache2 mysql-server mysql-client bison flex php5 php5-curl php5-cli php5-mysql php-pear php5-gd curl sox libncurses5-dev libssl-dev libmysqlclient-dev mpg123 libxml2-dev libnewt-dev sqlite3 libsqlite3-dev pkg-config automake libtool autoconf git unixodbc-dev uuid uuid-dev libasound2-dev libogg-dev libvorbis-dev libcurl4-openssl-dev libical-dev libneon27-dev libsrtp0-dev libspandsp-dev

# RUN apt-get update && apt-get install -y build-essential curl libgtk2.0-dev linux-headers-`uname -r` lynx libiksemel-dev mariadb-server mariadb php php-mysql php-mbstring tftp-server httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel audiofile-devel gtk2-devel subversion kernel-devel git php-process crontabs cronie cronie-anacron wget vim php-xml uuid-devel sqlite-devel net-tools gnutls-devel php-pear

RUN pear install Console_Getopt \
# Start maria DB
 && service mysql start \
# Make sure that NOBODY can access the server without a password
 && mysql -e "UPDATE mysql.user SET Password = PASSWORD('$ASTERISK_DB_PW') WHERE User = 'root'" \
# Kill the anonymous users
 && mysql -e "DROP USER ''@'localhost'" \
# Because our hostname varies we'll use some Bash magic here.
 && mysql -e "DROP USER ''@'$(hostname)'" \
# Kill off the demo database
 && mysql -e "DROP DATABASE test" \
# Make our changes take effect
 && mysql -e "FLUSH PRIVILEGES" \

# add asterisk user
 && groupadd -r $ASTERISKUSER \
 && useradd -r -g $ASTERISKUSER $ASTERISKUSER \
 && mkdir /var/lib/asterisk \
 && chown $ASTERISKUSER:$ASTERISKUSER /var/lib/asterisk \
 && usermod --home /var/lib/asterisk $ASTERISKUSER \
 && rm -rf /var/lib/apt/lists/* \
#  && curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' \
#  && chmod +x /usr/local/bin/gosu \
 && apt-get purge -y



#build pj project
#build jansson
WORKDIR /temp/src/
RUN git clone https://github.com/asterisk/pjproject.git 1>/dev/null \
  && git clone https://github.com/akheron/jansson.git 1>/dev/null \
  && cd /temp/src/pjproject \
  && ./configure --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr 1>/dev/null \
  && make dep 1>/dev/null \
  && make 1>/dev/null \
  && make install 1>/dev/null \
  && cd /temp/src/jansson \
  && autoreconf -i 1>/dev/null \
  && ./configure 1>/dev/null \
  && make 1>/dev/null \
  && make install 1>/dev/null \
  
# Download asterisk.
# Currently Certified Asterisk 13.1.
  && curl -sf -o /tmp/asterisk.tar.gz -L http://downloads.asterisk.org/pub/telephony/certified-asterisk/certified-asterisk-$ASTERISKVER-current.tar.gz 1>/dev/null \

# gunzip asterisk
  && mkdir /tmp/asterisk \
  && tar -xzf /tmp/asterisk.tar.gz -C /tmp/asterisk --strip-components=1 1>/dev/null \
  && rm -f /tmp/asterisk.tar.gz 1>/dev/null \
WORKDIR /tmp/asterisk

# make asterisk.
# ENV rebuild_date 2015-01-29
RUN mkdir /etc/asterisk \
# Configure
  && ./configure --with-ssl=/opt/local --with-crypto=/opt/local 1> /dev/null \
# Remove the native build option
  && make menuselect.makeopts 1>/dev/null \
#  && sed -i "s/BUILD_NATIVE//" menuselect.makeopts 1>/dev/null \
  && menuselect/menuselect --enable chan_sip --disable BUILD_NATIVE  --enable CORE-SOUNDS-EN-WAV --enable CORE-SOUNDS-EN-SLN16 --enable MOH-OPSOUND-WAV --enable MOH-OPSOUND-SLN16 menuselect.makeopts  menuselect.makeopts 1>/dev/null \
# Continue with a standard make.
  && make 1> /dev/null \
  && make install 1> /dev/null \
  && make config 1>/dev/null \
  && ldconfig \
  && chkconfig asterisk off \
# ateris sounds files
  && cd /var/lib/asterisk/sounds \
  && wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz 1>/dev/null \
  && tar xfz asterisk-extra-sounds-en-wav-current.tar.gz 1>/dev/null \
  && rm -f asterisk-extra-sounds-en-wav-current.tar.gz 1>/dev/null \
  && wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz 1>/dev/null \
  && tar xfz asterisk-extra-sounds-en-g722-current.tar.gz 1>/dev/null \
  && rm -f asterisk-extra-sounds-en-g722-current.tar.gz \
  && chown $ASRERISKUSER. /var/run/asterisk \
  && chown -R $ASTERISKUSER. /etc/asterisk \
  && chown -R $ASTERISKUSER. /var/lib/asterisk \
  && chown -R $ASTERISKUSER. /var/www/ \
  && chown -R $ASTERISKUSER. /var/www/* \
  && chown -R $ASTERISKUSER. /var/log/asterisk \
  && chown -R $ASTERISKUSER. /var/spool/asterisk \
  && chown -R $ASTERISKUSER. /var/run/asterisk \
  && chown -R $ASTERISKUSER. /var/lib/asterisk \
  && chown $ASTERISKUSER:$ASTERISKUSER /etc/freepbxbackup \
  && rm -rf /var/www/html \

#mod to apache
#Setup mysql
  && sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini \
  && -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf \
  && sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf \
  && service apache2 restart 1>/dev/null \
  && /etc/init.d/mysql start 1>/dev/null \
  && mysqladmin -u root create asterisk \
  && mysqladmin -u root create asteriskcdrdb \
  && mysql -u root -e "GRANT ALL PRIVILEGES ON asterisk.* TO $ASTERISKUSER@localhost IDENTIFIED BY '$ASTERISK_DB_PW';" \
  && mysql -u root -e "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO $ASTERISKUSER@localhost IDENTIFIED BY '$ASTERISK_DB_PW';" \
  && mysql -u root -e "flush privileges;"

WORKDIR /usr/src
RUN wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-$FREEPBXVER-latest.tgz 1>/dev/null 2>/dev/null \
  && ln -s /var/lib/asterisk/moh /var/lib/asterisk/mohmp3 \
  && tar vxfz freepbx-$FREEPBXVER-latest.tgz 1>/dev/null \
  && rm -f freepbx-$FREEPBXVER-latest.tgz 1>/dev/null \
  && /etc/init.d/mysql start 1>/dev/null \
  && /usr/src/freepbx/start_asterisk start 1>/dev/null \
  && /usr/src/freepbx/install -n 1>/dev/null \
  && && chown -R $ASTERISKUSER. /var/lib/asterisk/bin/retrieve_conf 1>/dev/null \

# Attempt to change default web port from 80 to $FREEPBXPORT - currently 8009
  && sed -i 's/Listen 80/Listen $FREEPBXPORT/' /etc/apache2/ports.conf \
  && sed -i 's/<VirtualHost *: 80>/<VirtualHost *: $FREEPBXPORT>/' /etc/apache2/sites-enabled/000-default.conf \
  && service apache2 restart \
#clean up
  && find /temp -mindepth 1 -delete \
  && apt-get purge -y \
  && apt-get --yes autoremove \
  && apt-get clean all \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   
CMD bash -C '/root/start.sh';'bash'
