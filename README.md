# QEMU notes

## Table of Contents
[[_TOC_]]

## Description
Compilation of useful information, scripts and cli options examples I learned whilst exploring QEMU

## Scripts 
### Bridged tap network setup
Use `create_bridged_tap.sh` to create bridge, bridge a tap interface and your ethernet interface to it. Then scripts attempts to get and IP address and network configuration from DHCP. 
```bash
chmod +x ./create_bridged_tap.sh
./create_bridged_tap.sh
```