#!/bin/bash

dirs=(
    'public_html'
);

SCRIPTDIR=$(dirname $0)


function fixperms {
    find $SCRIPTDIR/../$1 -type f -exec chmod 644 {} \; #applies to files
    find $SCRIPTDIR/../$1 -type d -exec chmod 755 {} \; # applies to dirs
}


for i in "${dirs[@]}"
do
    fixperms $i
done
