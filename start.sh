#!/bin/bash

# start apache
service apache2 start
# start mysql
/etc/init.d/mysql start
# start asterisk
/usr/src/freepbx/start_asterisk start
