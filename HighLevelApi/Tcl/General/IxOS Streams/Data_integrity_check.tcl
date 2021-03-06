################################################################################
# Version 1.0    $Revision: 1 $
#
#    Copyright � 1997 - 2005 by IXIA
#    All Rights Reserved.
#
################################################################################

################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications, enhancements and updates thereto (whether     #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the user's requirements or (ii) that the script will be without         #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, AND IXIA        #
# DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,          #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF, OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF,   #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS, LOST BUSINESS, LOST OR        #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT, INCIDENTAL, PUNITIVE OR            #
# CONSEQUENTIAL DAMAGES, EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF   #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g., any error corrections) in connection with the    #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script, any such services are subject to the warranty and   #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
###############################################################################

################################################################################
#                                                                              #
# Description:                                                                 #
#    This sample configures tx and rx ports for data integrity checking.       #
#    Prints out the statistics on the data_integrity_frames and                #
#    data_integrity_errors                                                     #
#                                                                              #
# Module:                                                                      #
#    The sample was tested on a LM100TXS8 module.                              #
#                                                                              #
################################################################################

package require Ixia

set test_name [info script]

set chassisIP sylvester
set port_list [list 2/3 2/4]

# Connect to the chassis, reset to factory defaults and take ownership
set connect_status [::ixia::connect \
        -reset                    \
        -device    $chassisIP     \
        -port_list $port_list     \
        -username  ixiaApiUser    ]
if {[keylget connect_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget connect_status log]"
}

set port_handle [list]
foreach port $port_list {
    if {![catch {keylget connect_status port_handle.$chassisIP.$port} \
            temp_port]} {
        lappend port_handle $temp_port
    }
}
set tx_port [lindex $port_handle 0]
set rx_port [lindex $port_handle 1]

########
# IpV4 #
########
set ipV4_port_list    "2/3            2/4"
set ipV4_ixia_list    "1.1.1.2        1.1.1.1"
set ipV4_gateway_list "1.1.1.1        1.1.1.2"
set ipV4_netmask_list "255.255.255.0  255.255.255.0"
set ipV4_mac_list     "0000.debb.0001 0000.debb.0002"
set ipV4_version_list "4           4"
set ipV4_autoneg_list "1              1"
set ipV4_duplex_list  "full           full"
set ipV4_speed_list   "ether100       ether100"

########################################
# Configure interface in the test      #
# IPv4                                 #
########################################
set interface_status [::ixia::interface_config    \
        -port_handle        $port_handle        \
        -intf_ip_addr       $ipV4_ixia_list     \
        -gateway            $ipV4_gateway_list  \
        -netmask            $ipV4_netmask_list  \
        -autonegotiation    $ipV4_autoneg_list  \
        -duplex             $ipV4_duplex_list   \
        -src_mac_addr       $ipV4_mac_list      \
        -port_rx_mode       data_integrity      \
        -data_integrity     1                   \
        -integrity_signature          a1b1c1d1  \
        -integrity_signature_offset   40        \
        -speed           $ipV4_speed_list       ]
if {[keylget interface_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget interface_status log]"
}

# Delete all the streams first
set traffic_status [::ixia::traffic_config \
        -mode        reset                 \
        -port_handle $tx_port          ]
if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

# Configure stream 1 
set traffic_status [::ixia::traffic_config \
        -mode         create               \
        -port_handle  $tx_port             \
        -l3_protocol  ipv4                 \
        -ip_src_addr  12.1.1.1             \
        -ip_dst_addr  12.1.1.2             \
        -l3_length    57                   \
        -rate_percent 50                   \
        -mac_dst_mode discovery            \
        -mac_src      0000.0005.0001       \
        -enable_data_integrity  1          \
        -integrity_signature    a1b1c1d1   \
        -integrity_signature_offset 40     ]

if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

########################################
# Traffic control                      #
########################################

# Clear stats before sending traffic
set clear_stats_status [::ixia::traffic_control \
        -port_handle $port_handle             \
        -action      clear_stats              ]
if {[keylget clear_stats_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget clear_stats_status log]"
}

# Start the traffic on TX port
set traffic_start_status [::ixia::traffic_control    \
        -port_handle $tx_port                   \
        -action      run                        ]
if {[keylget traffic_start_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_start_status log]"
}

# Sleep 5 seconds
ixia_sleep 5000

# Stop traffic on the TX port
set traffic_stop_status [::ixia::traffic_control \
    -port_handle $tx_port                      \
        -action      stop                      ]
if {[keylget traffic_stop_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_stop_status log]"
}

###############################################################################
#   Retrieve stats after stopped
###############################################################################
# Get aggregrate stats for all ports
set aggregate_stats [::ixia::traffic_stats -port_handle $port_handle]
if {[keylget aggregate_stats status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget aggregate_stats log]"
}

proc post_stats {port_handle label key_list stat_key {stream ""}} {
    puts -nonewline [format "%-25s" $label]

    foreach port $port_handle {
        if {$stream != ""} {
            set key $port.stream.$stream.$stat_key
        } else {
            set key $port.$stat_key
        }

        puts -nonewline "[format "%-16s" [keylget key_list $key]]"
    }
    puts ""
}

puts "\n\t\t########################"
puts "\t\t#  STATIC STATS        #"
puts "\t\t########################"
puts "\n******************* STATS **********************"
puts "[format "%30s%16s" $tx_port $rx_port]"
puts "[format "%30s%16s" ----- -----]"

post_stats $port_handle "Elapsed Time"          $aggregate_stats \
        aggregate.tx.elapsed_time
post_stats $port_handle "Packets Tx"            $aggregate_stats \
        aggregate.tx.pkt_count
post_stats $port_handle "Bytes Tx"              $aggregate_stats \
        aggregate.tx.pkt_byte_count
post_stats $port_handle "Packets Rx"            $aggregate_stats \
        aggregate.rx.pkt_count
post_stats $port_handle "Bytes Rx"              $aggregate_stats \
        aggregate.rx.pkt_byte_count
post_stats $port_handle "Data Integrity Frames" $aggregate_stats \
        aggregate.rx.data_int_frames_count
post_stats $port_handle "Data Integrity Error"  $aggregate_stats \
        aggregate.rx.data_int_errors_count

puts "*************************************************"

return "SUCCESS - $test_name - [clock format [clock seconds]]"
