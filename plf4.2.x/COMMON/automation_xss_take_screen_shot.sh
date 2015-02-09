#!/bin/bash

DEBUG_MODE=${DEBUG_MODE:-"false"}

if [ "${DEBUG_MODE}" == "true" ]; then
  set -xv
fi

output_prefix=$1
parentpid=$2
interval=$3
  mkdir ${output_prefix}_log
  pushd ${output_prefix}_log
counter=0
sleep 35
while true; do

  if [ ! -d /proc/${parentpid} ]; then
    echo "`date`, the parent process id ${parentpid} does not exist, exit"
    exit 0
  fi
  if [ `grep -c html ${output_prefix}` -gt 0 ]; then
    echo "`date`, the report ${output_prefix} done, exit"
    exit 0
  fi
  sleep $((interval - 2))
  #counter=$(( counter+1 ))
  
  timeout $((interval*2)) import -quality 40 -window root ./screen_`date +%m%d_%H%M%S`.png
done