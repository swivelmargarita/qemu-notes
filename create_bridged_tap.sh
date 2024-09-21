#! /usr/bin/env bash


BRIDGE_INTERFACE=""
TAP_INTERFACE=""
ETHERNET_INTERFACE=""

read_interface_names() {
    echo Enter the bridge interface name, default=br0
    read BRIDGE_INTERFACE
    BRIDGE_INTERFACE="${BRIDGE_INTERFACE:=br0}"
    echo Enter the tap interface name, default=tap0
    read TAP_INTERFACE
    TAP_INTERFACE="${TAP_INTERFACE:=tap0}"

    #TODO Handle devices with more than one eth interfaces
    existing_eth_interfaces=""
    for interface in "/sys/class/net/*"; do
        interface=`basename ${interface}`
        pattern='e*'
        if [[ "${interface}" =~ $pattern ]]; then
            existing_eth_interfaces="${existing_eth_interfaces}${interface}" 
        fi
    done
    echo -n Enter the ethernet interface name. 
    echo " Found: ${existing_eth_interfaces:=none}"
    read ETHERNET_INTERFACE
    [[ "${ETHERNET_INTERFACE}" ]] || { echo -n Using "${existing_eth_interfaces}"
                                          echo  " as interface..."; }
    ETHERNET_INTERFACE="${ETHERNET_INTERFACE:=${existing_eth_interfaces}}"

    if ! [[ -d "/sys/class/net/${ETHERNET_INTERFACE}"  ]]; then
        echo Wrong interface name, exiting...
        exit 1
    fi
    if [[ "${ETHERNET_INTERFACE}" == "lo" ]]; then
        echo Loopback cannot be selected
        exit 1
    fi
}

check_for_existing_net_devices() {
    echo Checking for already created network devices...
    local wanted_devices="${BRIDGE_INTERFACE} ${TAP_INTERFACE}" 
    local existing_devices=""
    for device in "${wanted_devices}"; do
        if [[ -d "/sys/devices/virtual/net/${device}" ]]; then
            existing_devices="${existing_devices}${device} "
        fi
    done
    echo "${existing_devices}" 
    if [[ "${exinsting_devices}" ]]; then
        echo -n Remove devices "${created_devices} "
        echo and restart the script:
        echo 'ip link del <interface>'
        echo Exiting...
        exit 1
    else
        echo No existing network devices br0 tap0 found. Continuing...
    fi
}

create_tap() {
    local readonly ARG="$@"
    if [[ "$2" ]]; then
        echo Only 1 argument, name of tap interface, is supported, exiting...
        exit 1
    fi
    sudo ip tap add "$ARG" mode tap user "${USER}"
}

create_bridge() {
    local readonly ARG="$@"
    if [[ "$2" ]]; then
        echo Only 1 argument, name of bridge interface, is supported, exiting...
        exit 1
    fi
    sudo ip link add "$ARG" type bridge
}

add_interfaces_to_bridge() {
    sudo ip link set "${ETHERNET_INTERFACE}" master "${BRIDGE_INTERFACE}"
    sudo ip link set "${TAP_INTERFACE}" master "${BRIDGE_INTERFACE}"
}

activate_interfaces() {
    sudo ip link set "${BRIDGE_INTERFACE}" up
    sudo ip link set "${TAP_INTERFACE}" up
}

add_ip_addresses() {
    echo  You need to set your IP address the interface br0 and clear IPs on "${ETHERNET_INTERFACE}"
    echo "Do you want to use DHCP on ${ETHERNET_INTERFACE} for IP address configuration? (y/n)"
    read answer
    [[ "${answer}" != "y" ]] && { echo "Selected no. Exiting..."  && exit 1; }
    echo Setting IP address and gateway...
    sudo dhcpcd "${BRIDGE_INTERFACE}"
    sudo ip addr flush "${ETHERNET_INTERFACE}"
}

#add_ip_addresses() {
#    echo -n You need to set your IP address and default gateway
#    echo on the interface br0 and clear IPs on "${ETHERNET_INTERFACE}"
#    echo "Do you want to copy configuration from ${ETHERNET_INTERFACE}? (y/n)"
#    read answer
#    [[ "${answer}" != "y" ]] && { echo "Select y or n. Exiting..." && cleanup && exit 1; }
#    echo Setting IP address and gateway...
#    ip_eth=`ip -j addr | jq -r '.[] | select(.ifname == env.ETHERNET_INTERFACE ) | .addr_info[] | select(.family == "inet") | .local'`
#    echo ~~~~~~~~~~~~~~~${ip_eth}~~~~~~~~~~~~~~~
#    prefix_eth=`ip -j addr | jq -r '.[] | select(.ifname == env.ETHERNET_INTERFACE ) | .addr_info[] | select(.family == "inet") | .prefixlen'`
#    echo ~~~~~~~~~~~~~~~${prefix_eth}~~~~~~~~~~~~~~~
#    broadcast_eth=`ip -j addr | jq -r '.[] | select(.ifname == env.ETHERNET_INTERFACE ) | .addr_info[] | select(.family == "inet") | .broadcast'`
#    echo ~~~~~~~~~~~~~~~${broadcast_eth}~~~~~~~~~~~~~~~
#    gateway_eth=`ip -j route | jq -r '.[] | select(.dst == "default") | .gateway'`
#    sudo ip addr add dev "${BRIDGE_INTERFACE}" local "${ip_eth}/${prefix_eth}" broadcast "${broadcast_eth}"
#    echo ~~~~~~~~~~~~~~~~~~~~~"$gateway_eth"~~~~~~~~~~~~~~~~
#    sudo ip route append default via "${gateway_eth}" dev "${BRIDGE_INTERFACE}"
#    [[ "$?" -eq 0 ]] && sudo ip addr del  "${ip_eth}/${prefix_eth}" dev "${ETHERNET_INTERFACE}"
#}

cleanup() {
    echo Deleting bridge ant tap interfaces...
    sudo ip link del "${TAP_INTERFACE}"
    sudo ip link del "${BRIDGE_INTERFACE}"
}

main() {
    #set -x
    read_interface_names
    check_for_existing_net_devices "${BRIDGE_INTERFACE}" "${TAP_INTERFACE}"
    create_tap "${TAP_INTERFACE}"
    create_bridge "${BRIDGE_INTERFACE}"
    add_interfaces_to_bridge "${BRIDGE_INTERFACE}" "${TAP_INTERFACE}" "${ETHERNET_INTERFACE}"
    activate_interfaces
    add_ip_addresses
}


main
