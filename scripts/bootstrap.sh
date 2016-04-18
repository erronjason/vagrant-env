#!/bin/bash

#apt-get update
#apt-get -y upgrade
#apt-get -y install pwgen php-pear php5-curl re2c imagemagick

# Generate our database passwords upon environment creation

MYSQL_USER="root"
MYSQL_PASSWORD="root"
MYSQL_HOST="localhost"
MYSQL_DB="scotchbox"

{
  echo "<?php";
  echo "define('DB_HOST', '$MYSQL_HOST');";
  echo "define('DB_USER', '$MYSQL_USER');";
  echo "define('DB_PASS', '$MYSQL_PASSWORD');";
  echo "define('DB_DB', '$MYSQL_DB');";
  echo "?>";
} > /var/www/admin/app/includes/dbconfig.php

cp /var/www/admin/app/includes/dbconfig.php /var/www/app/includes/dbconfig.php

#apt-get -y install apache2 php5 mysql-server libapache2-mod-auth-mysql php5-mysql php5-gd php5-dev php5-imagick
#sudo php5enmod imagick
#rm /var/www/html/index.html # Remove the default index apache places in this directory

# Destroy DB each time provisioned
mysql -p$MYSQL_PASSWORD -e "drop database $MYSQL_DB"
mysql -p$MYSQL_PASSWORD -e "create database $MYSQL_DB"

# Import our live DB
if [ -f /vagrant/scripts/db.sql ];
then
    mysql -u$MYSQL_USER -p"$MYSQL_PASSWORD" $MYSQL_DB < /vagrant/scripts/db.sql | mysql -u$MYSQL_USER -p$MYSQL_PASSWORD
fi

# If any .sql files reside in custom folder, import them
if [ -f /vagrant/scripts/sql/*.sql ];
then
    for i in $( ls /vagrant/scripts/sql/*.sql ); do
        mysql -u$MYSQL_USER -p"$MYSQL_PASSWORD" $MYSQL_DB < $i | mysql -u$MYSQL_USER -p$MYSQL_PASSWORD
    done
fi


# Add our local apache configurations
cp /vagrant/scripts/apache/brv.conf /etc/apache2/sites-enabled/
if [ ! -f /etc/apache2/sites-available/brv.conf ];
then
    ln -s /etc/apache2/sites-enabled/brv.conf /etc/apache2/sites-available/brv.conf
    rm /etc/apache2/sites-enabled/{scotchbox.local.conf,000-default.conf}
    rm /etc/apache2/sites-available/{scotchbox.local.conf,000-default.conf,default-ssl.conf}
fi

service apache2 restart

echo "
                                               -s
              -::+ss+-                        :mh
              mMMMMMMMs                      -mM:
             ;MMM  MMMM-  -/+/-      ;MM     yMs  /yysoo/
             hMMM.MMMNy/odMMMMN:     ;MM:;' :MN/hNMmsyyhy/
            oMMMMMNh+  mMMNMMMMh .my-:MMd- -hMo yMN:
           /NMMMMMMMh  mMM  MMy: MNMo/NMN: /Mm :MM+-
          :MMM  MMMMMy:MMMMNh/ -dF MdssMN- dM/-mMhyhh/
          yMMM.MMMMMN/oMmNM/  /mMhdM: -MN-oMd-mMo
         +MMMMMMMNy+--NM/:dN: /Nh dM- -NN+Mm-oMm+/:
         NNdmdyo:    /Md  -mN/dM: hM  :MMMM: -oyyyys
         /-          dM/   -oNM+  +d  :MMMy  ::
                    -Ms      oo        hMm-  dm
        -+shdddhyo-  s-                 -   oMo
        mMMMMMMMMMm:               /os+:   :Nm  -+ooss+
        'hMMM. .MMMNoshddy:      yMMMMMMy :dM/ sMNhso:
         +MMMMMMMMMmMMo+/ -sdMMd: sMM MMm dMy  mM/
         mMMMMMMmh+oMd    oMM MMm-hMMMMMmhMN- /MN-:-
        -MMm/--    dMdss  NMM.MMN-mMhyo: dMo  yMNds:
        oMM/      :MMo/: -MMMMMM/:MN-   yMh  -NM:
       -MMh       sMd   --sMMMd: yMs   oMN   sMM++oyhdh:
       sMM:       yMNmmmdy--/:   mM:   oMMNy./dmmhs+/:-
      -NMy        /o+:-         :Mm     -/
      sMN-                      oMy
      :s:                       hM/
                                ys
" > /etc/motd.tail
