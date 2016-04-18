#!/bin/bash

SCRIPTDIR=$(dirname $0)
printf "This will sync your project's public_html/media/ with the production source.\nDo you wish to continue? (Y/n) "
read prompt

mkdir -p $SCRIPTDIR/../public_html/media

if [ "$prompt" == "Y" ] || [ "$prompt" == "y" ] || [ "$prompt" == "" ]; then
  rsync -hvrPt --update --delete-after yourhostnamehere:public_html/media $SCRIPTDIR/../public_html/media
  echo "Sync complete!"
  exit 1
else
  echo "Sync cancelled"
fi
