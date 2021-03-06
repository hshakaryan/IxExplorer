################################################################################
# Version 1.0    $Revision: 1 $
#
#    Copyright � 1997 - 2006 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    3-09-2007 : Mircea Hasegan
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
#    This sample creates a FTP client and server configuration.                #
#    The client network is configured with PPPoE.                              #
#    The server network is configured with IPv4.                               #
#    10 real files are added to the FTP client and 10 real files to the        #
#    FTP server.                                                               #
#    Client is simulating 10 GET command on the real files from the server.    #
#    Client is simulating 10 PUT command using the real files from the client. #
#    FTP traffic is sent from client side to server side.                      #
#    At the end statistics are being retrieved.                                #
#                                                                              #
#         Test topology:                                                       #
#     ______________________  ___________________                              #
#     |     Ixia chassis   |  | 7200            |                              #
#     ----------------------  ------------------|                              #
#     |4/3 ixia_client_port|--| 5/0 pppoe serve7|                              #
#     |                    |  |                 |                              #
#     |4/4 ixia_server_port|--|       6/0       |                              #
#     |____________________|  |_________________|                              #
#                                                                              #
# Module:                                                                      #
#    The sample was tested on a ALM1000T8 module.                              #
#                                                                              #
################################################################################

################################################################################
#
# DUT configuration:                                                           
#                                                                              
# conf t
#                                                                             
# vpdn enable                                                                  
#                                                                              
# bba-group pppoe global                                                     
#  virtual-template 26                                                         
#  sessions per-vc limit 1000                                                  
#  sessions per-mac limit 1000                                                 
#                                                                              
# interface Loopback26                                                         
#  ip address 26.26.26.1 255.255.255.0                                         
#                                                                              
# ip local pool ixiaPool 26.26.26.2 26.26.26.254                                  
#                                                                              
# interface FastEthernet 5/0                                                   
#  no ip address                                                               
#  no ip route-cache cef                                                       
#  no ip route-cache                                                           
#  duplex half                                                                 
#  pppoe enable                                                               
#  no shut                                                                     
#                                                                              
# interface Virtual-Template26                                                 
#  mtu 1492                                                                    
#  ip unnumbered Loopback26                                                     
#  peer default ip address pool ixiaPool                                          
#  no keepalive                                                                
#  ppp max-bad-auth 20                                                         
#  ppp timeout retry 10                                                        
#
# interface FastEthernet 6/0
#  no shut
#  ip address 27.27.27.1 255.255.255.0                                                      
#                                                                              
################################################################################

package require Ixia

set test_name [info script]

set chassisIP sylvester
set tclServer winston-400t
set port_list [list 4/3 4/4]

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
set server_port [keylget \
        connect_status port_handle.$chassisIP.[lindex $port_list 1]]

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
set client_network_range [::ixia::L47_network                     \
        -handle                      $client_network_handle     \
        -property                    network_pool               \
        -mode                        add                        \
        -np_first_mac                "00:C6:12:02:01:00"        \
        -np_mac_incr_step            "00.00.00.00.00.01"        \
        -np_ip_count                 5                          \
        -np_range_type               pppoe                      \
        -np_setup_rate               100                        \
        -np_enable_throttling        1                          \
        -np_max_outstanding_sessions 1000                       \
        -np_server_response_timeout  60                         \
        -np_padi_timeout             10                         \
        -np_padr_timeout             10                         \
        -np_padi_retries             5                          \
        -np_padr_retries             5                          \
        -np_ac_selection             match_first                \
        -np_service_name             "service name"             \
        -np_ac_name                  "ac name"                  \
        -np_enable_redial            0                          \
        -np_redial_timeout           10                         \
        -np_redial_max               20                         \
        -np_mtu                      1492                       \
        -np_enable_echo_reply        1                          \
        -np_enable_echo_request      0                          \
        -np_echo_request_interval    60                         \
        -np_lcp_timeout              15                         \
        -np_lcp_retries              5                          \
        -np_auth_type                none                       ]
        
if {[keylget client_network_range status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_network_range log]"
}
set client_network_range_handle [keylget client_network_range network_pool_handle]

################################################################################
# Server network
################################################################################
set server_network [::ixia::L47_network                   \
        -target                         server           \
        -property                       network           \
        -mode                           add                   \
        -port_handle                    $server_port      \
        -grat_arp_enable                0               ]


if {[keylget server_network status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget server_network log]"
}
set server_network_handle [keylget server_network network_handle]

################################################################################
# Server network pool
################################################################################
set server_network_range [::ixia::L47_network              \
        -handle             $server_network_handle       \
        -property           network_pool                 \
        -mode               add                          \
        -np_first_ip        "27.27.27.27"                \
        -np_ip_count        1                            \
        -np_network_mask    "255.255.255.0"              \
        -np_gateway         "27.27.27.1"                 \
        -np_ip_incr_step    "0.0.0.1"                    \
        -np_first_mac       "00:C6:12:02:02:00"          \
        -np_mac_incr_step   "00.00.00.00.00.01"          ]

if {[keylget server_network_range status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget server_network_range log]"
}
set server_network_range_handle [keylget server_network_range network_pool_handle]


################################################################################
# Create a traffic server and an FTP agent
################################################################################

set server_status [::ixia::L47_ftp_server               \
        -mode                      add                  \
        -property                  server               \
        -ftp_port                  21                   \
        -esm_enable                0                    \
        -esm                       300                  ]

if {[keylget server_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget server_status log]"
}

set server1 [keylget server_status server_handle]
set server_agent1  [keylget server_status agent_handle]

################################################################################
# Add 10 real file to the server_agent1
# The must be a real file in the path specified
################################################################################

set server_files_list ""
for {set rf_count 0} {$rf_count < 10} {incr rf_count} {
    set server_status [::ixia::L47_ftp_server               \
            -mode                      add                  \
            -handle                    $server_agent1       \
            -property                  real_file            \
            -rf_name                   "/server$rf_count"   \
            -rf_payload_file                                \
                {C:\\Documents and Settings\\mhasegan\\Desktop\\temp.tcl}]
    
    if {[keylget server_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget server_status log]"
    }
    
    lappend server_files_list [keylget server_status real_file_handle]
}

################################################################################
# Create a traffic client and an FTP agent
################################################################################
set status_ftp [::ixia::L47_ftp_client                    \
        -mode                 add                        \
        -property             client                     \
        -user_name            "root"                     \
        -password             "noreply@ixiacom.com"      \
        -access_mode          active                     \
        -esm_enable           0                          \
        -esm                  300                        ]
        
if {[keylget status_ftp status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget status_ftp log]"
}
set client_handle1  [keylget status_ftp client_handle]
set client_agent1   [keylget status_ftp agent_handle]

################################################################################
# Add 10 real file to the client_agent1
# The must be a real file in the path specified
################################################################################

set client_files_list ""
for {set rf_count 0} {$rf_count < 10} {incr rf_count} {
    set client_status [::ixia::L47_ftp_client               \
            -mode                      add                  \
            -handle                    $client_agent1       \
            -property                  real_file            \
            -rf_name                   "/client$rf_count"   \
            -rf_payload_file {C:/perforce_HLT/main/Ixia.tcl}]
                
    
    if {[keylget client_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget client_status log]"
    }
    
    lappend client_files_list [keylget client_status real_file_handle]
}


################################################################################
# Create two actions for the FTP agent
################################################################################

# Get all 10 real files from server

foreach real_file $server_files_list {
    set status_ftp [::ixia::L47_ftp_client                      \
            -mode                 add                          \
            -handle               $client_agent1               \
            -property             action                       \
            -a_command            get                          \
            -a_destination        $server_agent1               \
            -a_user_name          "root"                       \
            -a_password           "noreply@ixiacom.com"        \
            -a_arguments          $real_file                   ]
            
    if {[keylget status_ftp status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget status_ftp log]"
    }
}

# Put all 10 real files from the client on the server
foreach real_file $client_files_list {
    set status_ftp [::ixia::L47_ftp_client                      \
            -mode                 add                          \
            -handle               $client_agent1               \
            -property             action                       \
            -a_command            put                          \
            -a_destination        $server_agent1               \
            -a_user_name          "root"                       \
            -a_password           "noreply@ixiacom.com"        \
            -a_arguments          $real_file                   ]
            
    if {[keylget status_ftp status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget status_ftp log]"
    }
}

################################################################################
# Create client mapping
################################################################################
set map_status [::ixia::L47_client_mapping                         \
        -mode                           add                      \
        -client_network_handle          $client_network_handle   \
        -client_traffic_handle          $client_handle1          \
        -objective_type                 users                    \
        -objective_value                20                       \
        -ramp_up_value                  5                        \
        -sustain_time                   20                       \
        -ramp_down_time                 20                       ]

if {[keylget map_status status] != $::SUCCESS} {
    return "FAIL - map_status - [keylget map_status log]"
}
set client_map1 [keylget map_status handles]

################################################################################
# Create server mapping
################################################################################
set map_status [::ixia::L47_server_mapping                    \
        -mode                        add                    \
        -server_network_handle       $server_network_handle \
        -server_traffic_handle       $server1               \
        -match_client_total_time     1                      \
        ]

if {[keylget map_status status] != $::SUCCESS} {
    return "FAIL - map_status - [keylget map_status log]"
}
set server_map1 [keylget map_status handles]


################################################################################
# Test settings
################################################################################

set results_dir [pwd]/results/[clock seconds]
set control_status [::ixia::L47_test                  \
        -mode                           add           \
        -map_handle                     [list         \
                            $client_map1 $server_map1]\
        -force_ownership_enable         1             \
        -reset_ports_enable             1             \
        -stats_required                 0             \
        -results_dir_enable             1             \
        -results_dir                    $results_dir  ]

if {[keylget control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget control_status log]"
}
set test_handle [keylget control_status handles]

################################################################################
# Add statistics
################################################################################
set client_stats_list {
        ftp_connections
        ftp_control_conn_established
        ftp_data_conn_established
        ftp_file_downloads_successful
        ftp_file_downloads_failed
        ftp_data_bytes_received
        ftp_control_bytes_sent
        ftp_control_bytes_received
}

set client_agg_list {
    sum
}

set ftp_client_stat [::ixia::L47_stats                                \
        -mode             add                                          \
        -aggregation_type $client_agg_list                             \
        -stat_name        $client_stats_list                           \
        -stat_type        client                                       \
        -protocol         ftp                                          ]

if {[keylget ftp_client_stat status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget ftp_client_stat log]"
}
set client_stat_handle [keylget ftp_client_stat handles]


################################################################################
# Start test
################################################################################
set control_status [::ixia::L47_test \
        -handle    $test_handle \
        -mode      start        ]

if {[keylget control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget control_status log]"
}

################################################################################
# Get statistics
################################################################################
set client_stats_result [::ixia::L47_stats \
        -mode   get                              \
        -handle $client_stat_handle              ]

if {[keylget client_stats_result status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget client_stats_result log]"
}

################################################################################
# Print client statistics
################################################################################

# The stat_required variable can be changed to print only one of the statistics
# e.g set stat_required packets_sent

set stat_required "all"
puts "CLIENT STATISTICS:"
foreach {stat_handle} [keylkeys client_stats_result] {
    if {$stat_handle != "status"} {
        set stat_handle_kl [keylget client_stats_result $stat_handle]
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

::ixia::cleanup_session
if {$error != ""} {
    ixPuts $error
} else  {
    return "SUCCESS - $test_name - [clock format [clock seconds]]"
}
