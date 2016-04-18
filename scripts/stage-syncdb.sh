#!/bin/bash

# Get db configuration settings
. $SCRIPTDIR/stage-dbconfig.sh

# Takes one argument, db location
retrieve_live_db() {
    mysqldump $LIVE_MYSQL_DB -u $LIVE_MYSQL_USER -p$LIVE_MYSQL_PASS --add-drop-table --quick --compress --single-transaction --skip-comments --verbose --hex-blob > $1
}

# Takes one argument, db location
import_db() {
    mysql -u $STAGE_MYSQL_USER -p$STAGE_MYSQL_PASS $STAGE_MYSQL_DB -f < $1
}
