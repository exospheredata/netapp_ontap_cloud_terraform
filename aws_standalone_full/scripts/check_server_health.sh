#!/bin/bash
set -e

cnt=0
echo "Validating connection to Webserver"
until $(curl --output /dev/null --silent --head --fail --insecure https://localhost)
  do
    if [ $cnt -ge 5 ]
      then
        echo "Giving up after ${cnt} attempts"
        break
      else
        cnt=$[$cnt+1]
    fi
    echo "Attempt #$[$cnt] failed.  Waiting $[60/$cnt] seconds"
    sleep $[60/$cnt]
  done
