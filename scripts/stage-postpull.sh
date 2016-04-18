#!/bin/bash

# Get the directory of the script itself
SCRIPTDIR=$(dirname $0)

LASTCOMMIT=$(cat $SCRIPTDIR/lastcommit)
CURRENTCOMMIT=$(git rev-parse HEAD)




# Verify if commit is new or old
if [ "$LASTCOMMIT" != "$CURRENTCOMMIT" ]; then
    . $SCRIPTDIR/stage-syncdb.sh

    # Clear staging db
    import_db "$SCRIPTDIR/stage-cleardb.sql"

    # Import and re-create database from the live server
    retrieve_live_db "$SCRIPTDIR/db.sql"
    import_db "$SCRIPTDIR/db.sql"
    rm "$SCRIPTDIR/db.sql"

    # Import all new sql
    for i in $( ls $SCRIPTDIR/sql/*.sql ); do
          import_db $i
    done

    # Write out new commit hash as our base
    echo $CURRENTCOMMIT > $SCRIPTDIR/lastcommit
fi
