#! /usr/bin/env bash
if [[ -d /sys/devices/virtual/net/tap0 ]]; then
    echo -n You have already a tap0 device. 
    echo Remove it and restart the script:
    echo  ip tap del tap0 mode tap
fi

