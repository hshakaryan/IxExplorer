################################################################################
# Version 1.0    $Revision: 1 $
#
#    Copyright � 1997 - 2006 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    3-07-2008 : Mircea Hasegan
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
################################################################################

################################################################################
#                                                                              #
# Description:                                                                 #
#    This sample uses an IxLoad Video client and a real Video server.          #
#    The real video server streams video content on 10 multicast addresses     #
#    A pool of 200 addresses is available for the client network side.         #
#    The IxLoad video client performes Join command on the 10 multicast        #
#    addresses.                                                                #
#    At the end statistics are being retrieved.                                #
#                                                                              #
# Module:                                                                      #
#    The sample was tested on a ALM1000T8 module.                              #
#                                                                              #
################################################################################

package require Ixia
set ::ixia::debug 1
set test_name [info script]

set chassisIP sylvester
set tclServer sylvester
set port_list [list 2/1]

set error ""
catch {
set connect_status [::ixia::connect   \
        -reset                      \
        -device     $chassisIP      \
        -port_list  $port_list      \
        -username   ixiaApiUser     ]

if {[keylget connect_status status] != $::SUCCESS} {
    puts "FAIL - $test_name - [keylget connect_status log]"
}

set client_port [keylget \
        connect_status port_handle.$chassisIP.[lindex $port_list 0]]

################################################################################
# Client network
################################################################################
set client_network [::ixia::L47_network                 \
        -target                         client          \
        -property                       network       \
        -mode                           add              \
        -port_handle                    $client_port  \
        -grat_arp_enable                0             ]
        
if {[keylget client_network status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_network log]"
}
set client_network_handle [keylget client_network network_handle]

################################################################################
# Client network pool
################################################################################
set client_network_range [::ixia::L47_network             \
        -handle              $client_network_handle     \
        -property            network_pool               \
        -mode                add                        \
        -np_first_ip         "192.168.1.10"               \
        -np_network_mask     "255.255.255.0"              \
        -np_ip_incr_step     "0.0.0.1"                  \
        -np_ip_count         200                        \
        -np_gateway          "0.0.0.0"                  ]

if {[keylget client_network_range status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_network_range log]"
}
set client_network_range_handle [keylget client_network_range network_pool_handle]

################################################################################
# Create a traffic client and video agent
################################################################################

set client_status [::ixia::L47_video_client                 \
        -bitrate_limit                          64000000    \
        -min_delay                              20          \
        -mode                                   add         \
        -property                               client      \
    ]
if {[keylget client_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_status log]"
}
set client_traffic_handle [keylget client_status client_handle]
set video_client_handle [keylget client_status agent_handle]

################################################################################
# Create a commands object
################################################################################

set client_status [::ixia::L47_video_client             \
        -mode               add                         \
        -handle             $video_client_handle        \
        -property           commands                    \
        -commands_id        JoinCommand                 \
        -duration_max                   15              \
        -duration_min                   15              \
        -group_address_count            10              \
        -start_group_address            "224.77.1.1"    \
        -watch_count                    10              \
    ]
if {[keylget client_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_status log]"
}
set iptv_commands_handle [keylget client_status commands_handle]


################################################################################
# Client traffic-network mapping
################################################################################
set map_status [::ixia::L47_client_mapping                       \
        -mode                           add                      \
        -client_network_handle          $client_network_handle   \
        -client_traffic_handle          $client_traffic_handle   \
        -objective_type                 users                    \
        -objective_value                200                      \
        -ramp_up_value                  20                       \
        -sustain_time                   300                      \
        -ramp_down_time                 20                       \
        -agent_handle                   $video_client_handle     \
    ]

if {[keylget map_status status] != $::SUCCESS} {
    return "FAIL - map_status - [keylget map_status log]"
}
set client_map1 [keylget map_status handles]


################################################################################
# Test settings
################################################################################

set results_dir [pwd]/results/[clock seconds]
puts $results_dir
set control_status [::ixia::L47_test                  \
        -mode                           add           \
        -map_handle                     [list         \
                            $client_map1]\
        -force_ownership_enable         1             \
        -reset_ports_enable             1             \
        -stats_required                 1             \
        -results_dir_enable             1             \
        -results_dir                    $results_dir  ]

if {[keylget control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget control_status log]"
}
set test_handle [keylget control_status handles]

################################################################################
# Client statistics
################################################################################
set client_stats_list {
    video_multicast_channels_requested
    video_multicast_requests_successful
    video_multicast_requests_failed
}
set stats_result [::ixia::L47_stats                \
        -mode                 add                  \
        -aggregation_type     sum                  \
        -stat_name            $client_stats_list   \
        -stat_type            client               \
        -protocol             video                ]

if {[keylget stats_result status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget stats_result log]"
}
set client_stat_handle1 [keylget stats_result handles]

set client_stats_list {
    video_simulated_users
    video_channel_switch_latency
    video_join_latency
}
set stats_result [::ixia::L47_stats                \
        -mode                 add                  \
        -aggregation_type     [list sum weighted_average weighted_average]     \
        -stat_name            $client_stats_list   \
        -stat_type            client               \
        -protocol             video                ]

if {[keylget stats_result status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget stats_result log]"
}
set client_stat_handle2 [keylget stats_result handles]

################################################################################
# Start test
################################################################################
set control_status [::ixia::L47_test \
        -handle    $test_handle      \
        -mode      start             ]

if {[keylget control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget control_status log]"
}


################################################################################
# Get statistics
################################################################################
set client_stats_result1 [::ixia::L47_stats      \
        -mode   get                              \
        -handle $client_stat_handle1             ]

if {[keylget client_stats_result1 status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_stats_result1 log]"
}

set client_stats_result2 [::ixia::L47_stats      \
        -mode   get                              \
        -handle $client_stat_handle2             ]

if {[keylget client_stats_result2 status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_stats_result2 log]"
}

################################################################################
# Print client statistics
################################################################################

# The stat_required variable can be changed to print only one of the statistics
# e.g set stat_required telnet_active_conn

set stat_required "all"
puts "CLIENT STATISTICS 1:"
foreach {stat_handle} [keylkeys client_stats_result1] {
    if {$stat_handle != "status"} {
        set stat_handle_kl [keylget client_stats_result1 $stat_handle]
        foreach {stat_type} [keylkeys stat_handle_kl] {
            set stat_type_kl [keylget stat_handle_kl $stat_type]
            foreach {stat_name} [keylkeys stat_type_kl] {
                if {$stat_name != $stat_required && $stat_required != "all" } {
                        continue
                }
                set stat_name_kl [keylget stat_type_kl $stat_name]
                set time_stamp [lindex $stat_name_kl end]
                foreach {key value} $time_stamp {
                    if {$key == ""} { set key N/A }
                    if {$value == ""} { set value N/A }
                    puts  -nonewline [format \
                            "%10s %10s %40s" $stat_handle $stat_type $stat_name]
                    
                    puts [format "%15s %15s" $key $value]
                }
            }
        }
    }
}


################################################################################
# Print server statistics
################################################################################
set stat_required "all"
puts "Client STATISTICS 2:"
foreach {stat_handle} [keylkeys client_stats_result2] {
    if {$stat_handle != "status"} {
        set stat_handle_kl [keylget client_stats_result2 $stat_handle]
        foreach {stat_type} [keylkeys stat_handle_kl] {
            set stat_type_kl [keylget stat_handle_kl $stat_type]
            foreach {stat_name} [keylkeys stat_type_kl] {
                if {$stat_name != $stat_required && $stat_required != "all" } {
                        continue
                }
                set stat_name_kl [keylget stat_type_kl $stat_name]
                foreach {time_stamp} $stat_name_kl {
                    foreach {key value} $time_stamp {
                        if {$key == ""} { set key N/A }
                        if {$value == ""} { set value N/A }
                        puts  -nonewline [format \
                                "%10s %10s %40s" $stat_handle $stat_type $stat_name]
                        
                        puts [format "%15s %15s" $key $value]
                    }
                }                
            }
        }
    }
}
} error
 
set cleanup_status [::ixia::cleanup_session ]

if {[keylget cleanup_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget cleanup_status log]"
}

return "SUCCESS - $test_name - [clock format [clock seconds]]"
