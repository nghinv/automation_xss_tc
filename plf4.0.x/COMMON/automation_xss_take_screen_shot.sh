#!/bin/bash -xv
output_prefix=$1
parentpid=$2
interval=$3
  mkdir ${output_prefix}_log
  pushd ${output_prefix}_log
counter=0
#kill -9 `ps aux | grep shutter | awk '{print $2}'`
sleep 10
while true; do

  if [ ! -d /proc/${parentpid} ]; then
    echo "`date`, the parent process id ${parentpid} does not exist, exit"
    exit 0
  fi
  if [ `grep -c html ${output_prefix}` -gt 0 ]; then
    echo "`date`, the report done, exit"
    exit 0
  fi
  sleep 2
#$((interval - 2))
  counter=$(( counter+1 ))
  #timeout ${interval} shutter -f -o ./screen_${counter}.jpg
  timeout $((interval*2)) import -window root ./screen_${counter}.jpg
done
