#!/usr/bin/tclsh

package req Ixia
source /home/hgee/MyIxiaWork/HLT/HltLib.tcl

set ixiaChassisIp 10.219.117.101
set userName hgee
set portList "1/1/1 1/1/2"
set port1 1/1/1
set port2 1/1/2

::ixHlt::ConnectToTrafficGenerator \
    -reset \
    -ixChassisIp $ixiaChassisIp \
    -ixosTclServerIp $ixiaChassisIp \
    -portList $portList \
    -userName $userName

# Uncomment these lines for debugging
#set ::ixia::logHltapiCommandsFlag 1
#set ::ixia::logHltapiCommandsFileName ixiaHltCommandsLog.txt

::ixHlt::InterfaceConfig \
    -mode config \
    -port_handle $port1 \
    -port_rx_mode auto_detect_instrumentation \
    -intf_ip_addr 1.1.1.1 \
    -gateway 1.1.1.254 \
    -netmask 255.255.255.0 \
    -src_mac_addr [::ixHlt::GetMacAddrForPort $port1]


::ixHlt::InterfaceConfig \
    -mode config \
    -port_handle $port2 \
    -port_rx_mode auto_detect_instrumentation \
    -intf_ip_addr 2.2.2.1 \
    -gateway 2.2.2.254 \
    -netmask 255.255.255.0 \
    -src_mac_addr [::ixHlt::GetMacAddrForPort $port2]


# NOTE!  Configuring TrafficConfig -stream_id must begin with
#        streamId 1. 2nd port is streamId 2 and so on
 
# transmit_mode options: single_burst or continuous
::ixHlt::TrafficConfig \
    -mode create \
    -port_handle $port1 \
    -enable_auto_detect_instrumentation 1 \
    -stream_id 1 \
    -rate_percent 100 \
    -transmit_mode continuous \
    -frame_size 100 \
    -mac_src [::ixHlt::GetMacAddrForPort $port1] \
    -mac_dst 00:01:01:02:00:01 \
    -ip_src_addr 1.1.1.1 \
    -ip_dst_addr 2.2.2.2 \
    -ethernet_type ethernetII \
    -vlan_id 2 \
    -vlan_user_priority 7


# transmit_mode options: single_burst or continuous
::ixHlt::TrafficConfig \
    -mode create \
    -port_handle $port2 \
    -enable_auto_detect_instrumentation 1 \
    -stream_id 2 \
    -rate_percent 40 \
    -transmit_mode continuous \
    -frame_size 90 \
    -mac_src [ixHlt::GetMacAddrForPort $port2] \
    -mac_dst 00:01:01:01:00:01 \
    -ip_src_addr 1.1.1.1 \
    -ip_dst_addr 2.2.2.2 \
    -ethernet_type ethernetII \
    -vlan_id 3 \
    -vlan_user_priority 2 


::ixHlt::StartTrafficHlt -txPort $portList

after 3000

# Uncomment this if running continuous traffic
::ixHlt::StopTraffic $portList

#::ixHlt::VerifyReceivedPktCount -txPorts $portList -listeningPorts $portList -expectedPorts $portList

::ixHlt::DisconnectIxia

