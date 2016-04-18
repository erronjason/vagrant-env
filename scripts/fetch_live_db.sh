#!/bin/bash

SCRIPTDIR=$(dirname $0)
echo $SCRIPTDIR
. $SCRIPTDIR/localconfig.sh

mysqldump $LIVE_DB_NAME -h $LIVE_DB_HOST -u $LIVE_DB_USER -p$LIVE_DB_PASS --add-drop-table --quick --compress --single-transaction --skip-comments --verbose --hex-blob --opt --quote-names --skip-set-charset --default-character-set=latin1 > $SCRIPTDIR/db.sql
