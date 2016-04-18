#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 2>&1
    exit 1
else
    echo "Dropping database scotchbox"
    mysql -proot -e "drop database scotchbox"
    echo "Creating database scotchbox"
    mysql -proot -e "create database scotchbox"

    echo "Loading in data from db.sql"
    mysql -proot scotchbox --default-character-set=utf8 < /vagrant/scripts/db.sql | mysql -proot
    if [ -f /vagrant/scripts/sql/*.sql ];
    then
        for i in $( ls /vagrant/scripts/sql/*.sql ); do
              echo "Loading in data from $i"
              mysql -proot scotchbox --default-character-set=utf8 < $i | mysql -proot
        done
    fi
    echo "Database 'scotchbox' has been re-created"
fi
