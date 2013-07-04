#!/bin/bash -xv
output_prefix=$1
parentpid=$2
interval=$3
while true; do
  if [ ! -d /proc/${parentpid} ]; then
    echo "`date`, the parent process id ${parentpid} does not exist, exit"
    exit 0
  fi
  if [ `grep -c html ${output_prefix}` -gt 0 ]; then
    echo "`date`, the report done, exit"
    exit 0
  fi
  sleep ${interval}
  shutter -f -e -o ${output_prefix}_%Y%m%d_%NN.jpg>>/dev/null
done
