#!/bin/bash

# start apache
service apache2 start
# start mysql
/etc/init.d/mysql start
# start asterisk
service asterisk start
