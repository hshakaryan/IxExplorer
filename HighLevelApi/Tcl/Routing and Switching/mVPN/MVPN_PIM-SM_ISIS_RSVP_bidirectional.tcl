################################################################################
# Version 1.0    $Revision: 1 $
#
#    Copyright � 1997 - 2006 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    17-01-2006  LRaicea
#
# Description:
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
#    This sample creates the following MVPN setup.                             #
#                                                                              #
#                                                                              #
#                                                              +-------+       #
#                                                           +--| MVRF1 | MVPN  #
#                                                 +-----+  /   +-------+       #
#                                             +---| PE1 |-+                    #
#    +----+                                  /    +-----+  \   +-------+       #
#    | CE |---+                             /               +--| MVRF2 | MVPN  #
#    +----+    \  +-----+   +----------+   /                   +-------+       #
#               --| DUT |---| Provider |---                                    #
#    +----+    /  +-----+   +----------+   \                   +-------+       #
#    | CE |---+                             \               +--| MVRF1 | MVPN  #
#    +----+                                  \    +-----+  /   +-------+       #
#                                             +---| PE2 |-+                    #
#                                                 +-----+  \   +-------+       #
#                                                           +--| MVRF2 | MVPN  #
#                                                              +-------+       #
#                                                                              #
#                                                                              #
# Protocols used:                                                              #
#    Provider Side EGP                - BGP                                    #
#    Provider Side IGP                - ISIS                                   #
#    Provider Side MPLS Protocol      - RSVP                                   #
#    Provider Side Multicast Protocol - PIM/SM                                 #
#    Customer Side Multicast Protocol - PIM/SM                                 #
#                                                                              #
# DUT configuration:                                                           #
#                                                                              #
#     ip vrf 500
#         rd 1:500
#         route-target export 1:500
#         route-target import 1:500
#         mdt default 239.1.1.1
# 
#     ip vrf 501
#         rd 1:501
#         route-target export 1:501
#         route-target import 1:501
#         mdt default 239.1.1.2
#         exit
# 
#     ip multicast-routing
#     ip multicast-routing vrf 500
#     ip multicast-routing vrf 501
#     no mpls ldp logging neighbor-changes
# 
#     interface Loopback901
#         ip address  110.0.110.1 255.255.255.255
#         ip pim sparse-mode
# 
#     interface Loopback5
#         ip address 5.5.5.5 255.255.255.0
#         ip pim sparse-mode
# 
#     interface GigabitEthernet1/38
#         description Provider
#         ip address 19.19.19.1 255.255.255.0
#         ip pim sparse-mode
#         ip router isis MPLS_Core
#         mpls label protocol ldp
#         mpls traffic-eng tunnels
#         tag-switching ip
#         ip rsvp bandwidth 10000 10000
# 
#     interface Tunnel2222
#         ip unnumbered Loopback901
#         no ip directed-broadcast
#         tunnel destination 2.2.2.2
#         tunnel mode mpls traffic-eng
#         tunnel mpls traffic-eng autoroute announce
#         tunnel mpls traffic-eng path-option 1 dynamic
# 
#     interface Tunnel2223
#         ip unnumbered Loopback901
#         no ip directed-broadcast
#         tunnel destination 2.2.2.3
#         tunnel mode mpls traffic-eng
#         tunnel mpls traffic-eng autoroute announce
#         tunnel mpls traffic-eng path-option 1 dynamic
# 
#     interface GigabitEthernet1/37
#         description CustomerSide
#         ip address 18.18.18.1 255.255.255.0
#         ip pim sparse-mode
#         tag-switching ip
# 
#     interface GigabitEthernet1/37.500
#         description CE1
#         encapsulation dot1Q 500
#         ip vrf forwarding 500
#         ip address 21.21.25.1 255.255.255.0
#         ip pim sparse-mode
#         no cdp enable
# 
#     interface GigabitEthernet1/37.501
#         description CE2
#         encapsulation dot1Q 501
#         ip vrf forwarding 501
#         ip address 21.21.26.1 255.255.255.0
#         ip pim sparse-mode
#         no cdp enable
# 
#     router isis MPLS_Core
#         net 49.1111.1111.1111.1111.00
#         is-type level-1
#         metric-style wide
#         mpls traffic-eng router-id Loopback901
#         mpls traffic-eng level-1
#         mpls traffic-eng level-2
# 
#     router bgp 1
#         bgp router-id 1.1.1.1
#         bgp cluster-id 1684275457
#         bgp log-neighbor-changes
#         neighbor 2.2.2.2 remote-as 1
#         neighbor 2.2.2.2 update-source Loopback901
#         neighbor 2.2.2.3 remote-as 1
#         neighbor 2.2.2.3 update-source Loopback901
# 
#         address-family vpnv4
#         neighbor 2.2.2.2 activate
#         neighbor 2.2.2.2 send-community extended
#         neighbor 2.2.2.3 activate
#         neighbor 2.2.2.3 send-community extended
#         exit-address-family
# 
#         address-family ipv4 vrf 501
#         no auto-summary
#         no synchronization
#         exit-address-family
# 
#         address-family ipv4 vrf 500
#         no auto-summary
#         no synchronization
#         exit-address-family
#         exit
# 
#     ip pim rp-address 5.5.5.5
#     ip pim vrf 500 rp-address 21.21.25.1
#     ip pim vrf 501 rp-address 21.21.26.1
# 
# Module:                                                                      #
#    The sample was tested on a LM1000STXS4 module.                            #
#                                                                              #
################################################################################

proc script_increment_ipv4_address {prefix intf_ip_addr_step} {
    
    set temp_route_ip_addr_step [split $intf_ip_addr_step .]
    set step_index 3
    set octet_number 4
    while {$octet_number >= 1} {
        set single_octet_step [lindex $temp_route_ip_addr_step\
                $step_index]
        set one   0
        if {[scan $prefix "%d.%d.%d.%d" a b c d] == 4} {
            set one   [format %u [expr ($a<<24)|($b<<16)|($c<<8)|$d]]
        }
        set two [expr {$single_octet_step<<(8*(4-$octet_number))}]
        set value [expr {$one + $two}]
        if [catch {set prefix [format "%s.%s.%s.%s" \
                    [expr {(($value >> 24) & 0xff)}] \
                    [expr {(($value >> 16) & 0xff)}] \
                    [expr {(($value >> 8 ) & 0xff)}] \
                    [expr {$value & 0xff}]]} prefix] {
            set prefix 0.0.0.0
        }
        
        incr octet_number -1
        incr step_index -1
    }
    return $prefix
}

proc script_increment_ipv4_net {ipAddress {netmask 24} {amount 1}} {
    set ipVal   0
    if {[scan $ipAddress "%d.%d.%d.%d" a b c d] == 4} {
        set ipVal   [format %u [expr ($a<<24)|($b<<16)|($c<<8)|$d]]
    }
    set ipVal [mpexpr {($ipVal >> (32 - $netmask)) + $amount}]
    set ipVal [mpexpr {($ipVal << (32 - $netmask)) & 0xFFFFFFFF}]
    if [catch {set address [format "%s.%s.%s.%s" \
                [expr {(($ipVal >> 24) & 0xff)}] \
                [expr {(($ipVal >> 16) & 0xff)}] \
                [expr {(($ipVal >> 8 ) & 0xff)}] \
                [expr {$ipVal & 0xff}]]} address] {
        set address 0.0.0.0
    }
    return $address
}


package require Ixia

set test_name [info script]

set chassisIP sylvester
set port_list [list 4/1 4/2]

# Provider Side parameters
set p_ip_addr_start 19.19.19.2
set p_ip_addr_step  0.0.0.0
set p_gw_addr       19.19.19.1
set p_gw_addr_step  0.0.0.0
set p_ip_prefix     24
set p_rp_addr_start 5.5.5.5
set p_rp_addr_step  0.0.0.0

# Set PE Routers parameters
set pe_count             2
set pe_ip_addr_start     2.2.2.2
set pe_ip_addr_step      0.0.0.1
set pe_dut_ip_addr_start 110.0.110.1
set pe_dut_ip_addr_step  0.0.0.0
set pe_ip_prefix         32
set pe_as_number         1

# Set MVPN/MVRF parameters
set mvrf_count                2
set mvrf_unique               0
set rd_type                   as
set rd_number_start           $pe_as_number
set rd_number_step            0
set rd_assigned_number_start  500
set rd_assigned_number_step   1

set mvpn_source_addr_start    88.0.0.1
set mvpn_source_addr_step     0.0.1.0
set mvpn_source_prefix        32
set mvpn_num_sources          1

set mvpn_group_addr_start     228.0.0.1
set mvpn_group_addr_step      1.0.0.0
set mvpn_group_prefix         32
set mvpn_num_groups           1

set mvpn_rp_addr_start        21.21.25.1
set mvpn_rp_addr_step         0.0.1.0

set mdt_group_addr_start      239.1.1.1
set mdt_group_addr_step       0.0.0.1
set mdt_group_prefix          32


# Set Customer CE Parameters
set ce_ip_addr_start  21.21.25.2
set ce_ip_addr_step   0.0.1.0
set ce_ip_prefix      24
set ce_gw_addr_start  21.21.25.1
set ce_gw_addr_step   0.0.1.0
set ce_vlan_id_start  500
set ce_vlan_id_step   1
set ce_rp_addr_start  21.21.25.1
set ce_rp_addr_step   0.0.1.0

# Set CE multicast parameters (for bidirectional traffic)
set ce_mcast_source_addr_start    21.21.25.2
set ce_mcast_source_addr_step     0.0.1.0
set ce_mcast_source_prefix        32
set ce_mcast_num_sources          1

set ce_mcast_group_addr_start     230.0.0.1
set ce_mcast_group_addr_step      1.0.0.0
set ce_mcast_group_prefix         32
set ce_mcast_num_groups           1

if {$mvrf_unique} {
    set ce_count [mpexpr $pe_count * $mvrf_count]
} else  {
    set ce_count $mvrf_count
}
set total_mvrf_count $ce_count

################################################################################
# Connect to the chassis, reset to factory defaults and take ownership
################################################################################
# When using P2NO HLTSET, for loading the IxTclNetwork package please 
# provide �ixnetwork_tcl_server parameter to ::ixia::connect
set connect_status [::ixia::connect \
        -reset                      \
        -device    $chassisIP       \
        -port_list $port_list       \
        -username  ixiaApiUser      ]
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

################################################################################
# Configure interfaces in the test
################################################################################
set interface_status [::ixia::interface_config \
        -port_handle     $port_handle          \
        -autonegotiation 1                     \
        -duplex          full                  \
        -speed           ether1000             ]
if {[keylget interface_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget interface_status log]"
}

set pe_port_handle [lindex $port_handle 0]
set ce_port_handle [lindex $port_handle 1]

################################################################################
# Configure BGP PE
################################################################################
set bgp_routers_status [::ixia::emulation_bgp_config                  \
        -mode                            reset                      \
        -port_handle                     $pe_port_handle            \
        -count                           $pe_count                  \
        -local_ip_addr                   $p_ip_addr_start           \
        -remote_ip_addr                  $p_gw_addr                 \
        -local_addr_step                 0.0.0.0                    \
        -remote_addr_step                0.0.0.0                    \
        -local_loopback_ip_addr          $pe_ip_addr_start          \
        -local_loopback_ip_addr_step     $pe_ip_addr_step           \
        -remote_loopback_ip_addr         $pe_dut_ip_addr_start      \
        -remote_loopback_ip_addr_step    $pe_dut_ip_addr_step       \
        -local_router_id                 $pe_ip_addr_start          \
        -neighbor_type                   internal                   \
        -ip_version                      4                          \
        -local_as                        $pe_as_number              \
        -active_connect_enable                                      \
        -ipv4_unicast_nlri                                          \
        -ipv4_multicast_nlri                                        \
        -ipv4_mpls_nlri                                             \
        -ipv4_mpls_vpn_nlri                                         \
        -ipv6_unicast_nlri                                          \
        -ipv6_multicast_nlri                                        \
        -ipv6_mpls_nlri                                             \
        -ipv6_mpls_vpn_nlri                                         ]

if {[keylget bgp_routers_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget bgp_routers_status log]"
}
set pe_bgp_handles [keylget bgp_routers_status handles]

################################################################################
# Configure BGP MVRFs
################################################################################
set mvpn_source_address   $mvpn_source_addr_start
set mvpn_group_address    $mvpn_group_addr_start
set mdt_group_address     $mdt_group_addr_start
set rd_number             $rd_number_start
set rd_assigned_number    $rd_assigned_number_start

foreach {bgp_neighbor} $pe_bgp_handles {
    set mvpn_source_address_start $mvpn_source_address
    for {set i 1} {$i <= $mvrf_count} {incr i} {
        set bgp_route_range_status [::ixia::emulation_bgp_route_config \
                -mode                      add                       \
                -handle                    $bgp_neighbor             \
                -num_sites                 1                         \
                -num_routes                $mvpn_num_sources         \
                -max_route_ranges          1                         \
                -ip_version                4                         \
                -prefix                    $mvpn_source_address      \
                -prefix_step               1                         \
                -prefix_from               $mvpn_source_prefix       \
                -prefix_to                 $mvpn_source_prefix       \
                -route_ip_addr_step        0.0.0.0                   \
                -netmask                   255.255.255.255           \
                -default_mdt_ip            $mdt_group_address        \
                -default_mdt_ip_incr       $mdt_group_addr_step      \
                -label_value               16                        \
                -label_step                0                         \
                -rd_admin_value            $rd_number                \
                -rd_assign_value           $rd_assigned_number       \
                -rd_type                   0                         \
                -target_type               as                        \
                -target                    $rd_number                \
                -target_assign             $rd_assigned_number       \
                -import_target_type        as                        \
                -import_target             $rd_number                \
                -import_target_assign      $rd_assigned_number       \
                -ipv4_unicast_nlri                                   \
                -ipv4_multicast_nlri                                 \
                -ipv4_mpls_nlri                                      \
                -ipv4_mpls_vpn_nlri                                  \
                -origin_route_enable                                 \
                -next_hop_set_mode         same                      \
                -next_hop_enable           1                         ]
        
        if {[keylget bgp_route_range_status status] != $::SUCCESS} {
            return "FAIL - $test_name - [keylget bgp_route_range_status log]"
        }
        
        set mvpn_source_address [script_increment_ipv4_address \
                $mvpn_source_address $mvpn_source_addr_step]
        
        set mvpn_group_address  [script_increment_ipv4_address \
                $mvpn_group_address  $mvpn_group_addr_step]
        
        set mdt_group_address   [script_increment_ipv4_address \
                $mdt_group_address  $mdt_group_addr_step]
        
        set rd_number           [mpexpr $rd_number + $rd_number_step]
        set rd_assigned_number  [mpexpr $rd_assigned_number +  \
                $rd_assigned_number_step]
    }
    if {$mvrf_unique == 0} {
        set mvpn_source_address   $mvpn_source_address_start
        set mvpn_group_address    $mvpn_group_addr_start
        set mdt_group_address     $mdt_group_addr_start
        set rd_number             $rd_number_start
        set rd_assigned_number    $rd_assigned_number_start
        
        for {set i 0} {$i < $mvpn_num_sources} {incr i} {
            set mvpn_source_address   [script_increment_ipv4_net \
                    $mvpn_source_address $mvpn_source_prefix]
        }
    }
}

################################################################################
# Configure ISIS P/PE
################################################################################
set isis_router_status [::ixia::emulation_isis_config      \
        -mode                           create           \
        -reset                                                    \
        -port_handle                    $pe_port_handle  \
        -intf_ip_addr                   $p_ip_addr_start \
        -gateway_ip_addr                $p_gw_addr       \
        -intf_ip_prefix_length          $p_ip_prefix     \
        -count                                1                \
        -intf_metric                    0                \
        -routing_level                  L1L2             \
        -te_enable                      1                \
        -area_id                        "49 11 11 11"    \
        -system_id                      0x111111114900   \
        -te_router_id                   $p_ip_addr_start ]
if {[keylget isis_router_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget isis_router_status log]"
}

set provider_isis_handle [keylget isis_router_status handle]

set route_config_status [::ixia::emulation_isis_topology_route_config \
        -mode                   create                  \
        -handle                 $provider_isis_handle   \
        -type                   grid                    \
        -ip_version             4                       \
        -grid_row               2                       \
        -grid_col               1                       \
        -grid_start_te_ip       $pe_ip_addr_start       \
        -grid_te_ip_step        $pe_ip_addr_step        \
        -grid_start_system_id   000000000044            \
        -grid_stub_per_router   0                       \
        -grid_link_type         ptop                    \
        -grid_ip_start          144.144.144.144         \
        -grid_te                1                       \
        -link_enable            1                       ]

if {[keylget route_config_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget route_config_status log]"
}

################################################################################
# Configure RSVP P/PE 
################################################################################
set rsvp_config_status [::ixia::emulation_rsvp_config   \
        -mode                       create              \
        -reset                                          \
        -port_handle                 $pe_port_handle    \
        -count                       1                  \
        -egress_label_mode           imnull             \
        -ip_version                  4                  \
        -intf_ip_addr                $p_ip_addr_start   \
        -intf_ip_addr_step           $p_ip_addr_step    \
        -intf_prefix_length          $p_ip_prefix       \
        -neighbor_intf_ip_addr       $p_gw_addr         \
        -neighbor_intf_ip_addr_step  $p_gw_addr_step    ]

if {[keylget rsvp_config_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget rsvp_config_status log]"
}
set provider_rsvp_handle [keylget rsvp_config_status handles]

set pe_ip_address $pe_ip_addr_start
for {set i 0} {$i < $pe_count} {incr i} {
    set rsvp_tunnel_config_status [::ixia::emulation_rsvp_tunnel_config \
            -mode                               create                  \
            -handle                             $provider_rsvp_handle   \
            -rsvp_behavior                      rsvpIngress             \
            -count                              1                       \
            -egress_ip_addr                     $pe_dut_ip_addr_start   \
            -egress_ip_step                     $pe_dut_ip_addr_step    \
            -ingress_ip_addr                    $pe_ip_address          \
            -ingress_ip_step                    $pe_ip_addr_step        \
            -ingress_bandwidth                  1000                    \
            -session_attr_ra_include_all        0x11223344              \
            -lsp_id_start                       100                     \
            -tunnel_id_start                    5                       \
            -tunnel_id_count                    1                       \
            -tunnel_id_step                     10                      \
            -session_attr_name                  MyAttr1                 ]
    
    if {[keylget rsvp_tunnel_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget rsvp_tunnel_config_status log]"
    }
    
    set rsvp_tunnel_config_status [::ixia::emulation_rsvp_tunnel_config   \
            -mode                        create                           \
            -handle                      $provider_rsvp_handle            \
            -rsvp_behavior               rsvpEgress                       \
            -count                       1                                \
            -egress_ip_addr              $pe_ip_address                   \
            -egress_ip_step              $pe_ip_addr_start                ]
    
    if {[keylget rsvp_tunnel_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget rsvp_tunnel_config_status log]"
    }
    set pe_ip_address   [script_increment_ipv4_address \
            $pe_ip_address $pe_ip_addr_step]
}

##############################################################################
#  Configure PIM P/PE
##############################################################################
set pim_config_status [::ixia::emulation_pim_config             \
        -mode                       create                      \
        -reset                                                  \
        -port_handle                $pe_port_handle             \
        -count                      1                           \
        -ip_version                 4                           \
        -intf_ip_addr               $p_ip_addr_start            \
        -intf_ip_addr_step          $p_ip_addr_step             \
        -intf_ip_prefix_length      $p_ip_prefix                \
        -dr_priority                0                           \
        -bidir_capable              0                           \
        -hello_interval             30                          \
        -hello_holdtime             105                         \
        -join_prune_interval        60                          \
        -join_prune_holdtime        180                         \
        -prune_delay_enable         1                           \
        -prune_delay                500                         \
        -override_interval          2500                        \
        -gateway_intf_ip_addr       $p_gw_addr                  \
        -gateway_intf_ip_addr_step  0.0.0.0                     \
        -prune_delay_tbit           0                           \
        -send_generation_id         1                           \
        -generation_id_mode         constant                    \
        -mvpn_enable                1                           \
        -mvpn_pe_ip                 $pe_ip_addr_start           \
        -mvpn_pe_ip_incr            $pe_ip_addr_step            \
        -mvpn_pe_count              $pe_count                   \
        -mvrf_count                 $mvrf_count                 \
        -mvrf_unique                0                           \
        -default_mdt_ip             $mdt_group_addr_start       \
        -default_mdt_ip_incr        $mdt_group_addr_step        ]
if {[keylget pim_config_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget pim_config_status log]"
}
set provider_pim_handle [lindex [keylget pim_config_status handle] 0]
set pe_pim_handles      [lrange [keylget pim_config_status handle] 1 end]

################################################################################
# Create PIM MVPN sources on each PE
################################################################################
set mvpn_source_address  $mvpn_source_addr_start
set mvpn_group_address   $mvpn_group_addr_start
foreach {pe_pim_handle}  $pe_pim_handles {
    # Create multicast source pool
    set pim_config_status [::ixia::emulation_multicast_source_config \
            -mode               create                   \
            -num_sources        $mvpn_num_sources        \
            -ip_addr_start      $mvpn_source_address     \
            -ip_addr_step       $mvpn_source_addr_step   \
            -ip_prefix_len      $mvpn_source_prefix      \
            ]
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mvpn_source_pool_handle [keylget pim_config_status handle]
    
    # Create multicast group pool
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create                   \
            -num_groups         $mvpn_num_groups         \
            -ip_addr_start      $mvpn_group_address      \
            -ip_addr_step       $mvpn_group_addr_step    \
            -ip_prefix_len      $mvpn_group_prefix       \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mvpn_group_pool_handle [keylget pim_config_status handle]
    
    # Create PIM Source
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $pe_pim_handle              \
            -group_pool_handle      $mvpn_group_pool_handle     \
            -source_pool_handle     $mvpn_source_pool_handle    \
            -rp_ip_addr             $mvpn_rp_addr_start         \
            -rp_ip_addr_step        $mvpn_rp_addr_step          \
            -group_pool_mode        register                    \
            -join_prune_aggregation_factor 10                   \
            -wildcard_group                 1                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    if {$mvrf_unique == 0} {
        set mvpn_group_address      $mvpn_group_addr_start
        for {set i 0} {$i < $mvpn_num_sources} {incr i} {
            set mvpn_source_address   [script_increment_ipv4_net \
                    $mvpn_source_address $mvpn_source_prefix]
        }
    } else {
        for {set i 0} {$i < $mvrf_count} {incr i} {
            set mvpn_group_address   [script_increment_ipv4_address \
                    $mvpn_group_address $mvpn_group_addr_step]
            
            set mvpn_source_address   [script_increment_ipv4_address \
                    $mvpn_source_address $mvpn_source_addr_step]
        }
    }
}

################################################################################
# Create PIM MVPN groups on each PE (for bidirectional traffic)
################################################################################
set ce_mcast_group_address  $ce_mcast_group_addr_start
foreach {pe_pim_handle}  $pe_pim_handles {
    # Create multicast group pool
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create                    \
            -num_groups         1                         \
            -ip_addr_start      $ce_mcast_group_address   \
            -ip_addr_step       $ce_mcast_group_addr_step \
            -ip_prefix_len      $ce_mcast_group_prefix    \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set ce_mcast_group_pool_handle [keylget pim_config_status handle]
    
    # Create PIM Group
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $pe_pim_handle              \
            -group_pool_handle      $ce_mcast_group_pool_handle \
            -rp_ip_addr             $mvpn_rp_addr_start         \
            -rp_ip_addr_step        $mvpn_rp_addr_step          \
            -join_prune_aggregation_factor 10                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    
    set ce_mcast_group_address   $ce_mcast_group_addr_start
}

################################################################################
# Create PIM MDT sources on each PE
################################################################################
set mdt_source_address     $pe_ip_addr_start
set mdt_source_addr_step   $pe_ip_addr_step
set mdt_source_prefix      $pe_ip_prefix
set mdt_num_sources        1
set mdt_group_address      $mdt_group_addr_start
foreach {pe_pim_handle} $pe_pim_handles {
    # Create multicast source
    set pim_config_status [::ixia::emulation_multicast_source_config \
            -mode               create                   \
            -num_sources        $mdt_num_sources         \
            -ip_addr_start      $mdt_source_address      \
            -ip_addr_step       $mdt_source_addr_step    \
            -ip_prefix_len      $mdt_source_prefix       \
            ]
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mdt_source_pool_handle [keylget pim_config_status handle]
    
    # Create multicast group
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create              \
            -num_groups         $mvrf_count         \
            -ip_addr_start      $mdt_group_address  \
            -ip_addr_step       0.0.0.0             \
            -ip_prefix_len      32                  \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mdt_group_pool_handle [keylget pim_config_status handle]
    
    # Create PIM Source
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $pe_pim_handle              \
            -group_pool_handle      $mdt_group_pool_handle      \
            -source_pool_handle     $mdt_source_pool_handle     \
            -rp_ip_addr             $p_rp_addr_start            \
            -rp_ip_addr_step        0.0.0.0                     \
            -group_pool_mode        register                    \
            -join_prune_aggregation_factor 10                   \
            -wildcard_group                 1                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -register_tx_iteration_gap      6000                \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            -send_null_register             1                   \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    
    if {$mvrf_unique == 0} {
        set mdt_group_address      $mdt_group_addr_start
        for {set i 0} {$i < $mdt_num_sources} {incr i} {
            set mdt_source_address   [script_increment_ipv4_net \
                    $mdt_source_address $mdt_source_prefix]
        }
    } else {
        for {set i 0} {$i < $mvrf_count} {incr i} {
            set mdt_group_address   [script_increment_ipv4_address \
                    $mdt_group_address $mdt_group_addr_step]
            
            set mvpn_source_address   [script_increment_ipv4_address \
                    $mdt_source_address $mdt_source_addr_step]
        }
    }
}

################################################################################
# Create PIM MDT groups on each PE (for bidirectional traffic)
################################################################################
set mdt_source_address     $pe_ip_addr_start
set mdt_source_addr_step   $pe_ip_addr_step
set mdt_source_prefix      $pe_ip_prefix
set mdt_num_sources        1
set mdt_group_address      $mdt_group_addr_start
foreach {pe_pim_handle} $pe_pim_handles {
    # Create multicat source
    set pim_config_status [::ixia::emulation_multicast_source_config \
            -mode               create                   \
            -num_sources        $mdt_num_sources         \
            -ip_addr_start      $mdt_source_address      \
            -ip_addr_step       $mdt_source_addr_step    \
            -ip_prefix_len      $mdt_source_prefix       \
            ]
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mdt_source_pool_handle [keylget pim_config_status handle]
    
    # Create multicast group
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create              \
            -num_groups         $mvrf_count         \
            -ip_addr_start      $mdt_group_address  \
            -ip_addr_step       0.0.0.0             \
            -ip_prefix_len      32                  \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mdt_group_pool_handle [keylget pim_config_status handle]
    
    # Create PIM Group
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $pe_pim_handle              \
            -group_pool_handle      $mdt_group_pool_handle      \
            -source_pool_handle     $mdt_source_pool_handle     \
            -rp_ip_addr             $p_rp_addr_start            \
            -rp_ip_addr_step        0.0.0.0                     \
            -group_pool_mode        send                        \
            -join_prune_aggregation_factor 10                   \
            -wildcard_group                 1                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -register_tx_iteration_gap      6000                \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            -send_null_register             1                   \
            ]

    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    
    if {$mvrf_unique == 0} {
        set mdt_group_address      $mdt_group_addr_start
        for {set i 0} {$i < $mdt_num_sources} {incr i} {
            set mdt_source_address   [script_increment_ipv4_net \
                    $mdt_source_address $mdt_source_prefix]
        }
    } else {
        for {set i 0} {$i < $mvrf_count} {incr i} {
            set mdt_group_address   [script_increment_ipv4_address \
                    $mdt_group_address $mdt_group_addr_step]
            
            set mvpn_source_address   [script_increment_ipv4_address \
                    $mdt_source_address $mdt_source_addr_step]
        }
    }
}

################################################################################
# Create PIM Provider groups
################################################################################
set mdt_group_address $mdt_group_addr_start
for {set i 0} {$i < $total_mvrf_count} {incr i} {
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create              \
            -num_groups         1                   \
            -ip_addr_start      $mdt_group_address  \
            -ip_addr_step       0.0.0.0             \
            -ip_prefix_len      32                  \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mdt_group_pool_handle [keylget pim_config_status handle]
    
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $provider_pim_handle        \
            -group_pool_handle      $mdt_group_pool_handle      \
            -rp_ip_addr             $p_rp_addr_start            \
            -rp_ip_addr_step        0.0.0.0                     \
            -join_prune_aggregation_factor 10                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    
    set mdt_group_address [script_increment_ipv4_address \
            $mdt_group_address $mdt_group_addr_step]
}

################################################################################
# Configure PIM CE Routers
################################################################################
set pim_config_status [::ixia::emulation_pim_config             \
        -mode                       create                      \
        -reset                                                  \
        -port_handle                $ce_port_handle             \
        -count                      $ce_count                   \
        -ip_version                 4                           \
        -intf_ip_addr               $ce_ip_addr_start           \
        -intf_ip_addr_step          $ce_ip_addr_step            \
        -vlan_id                    $ce_vlan_id_start           \
        -vlan_id_step               $ce_vlan_id_step            \
        -dr_priority                0                           \
        -bidir_capable              0                           \
        -hello_interval             30                          \
        -hello_holdtime             105                         \
        -join_prune_interval        60                          \
        -join_prune_holdtime        180                         \
        -prune_delay_enable         1                           \
        -prune_delay                500                         \
        -override_interval          2500                        \
        -gateway_intf_ip_addr       $ce_gw_addr_start           \
        -gateway_intf_ip_addr_step  $ce_gw_addr_step            \
        -prune_delay_tbit           0                           \
        -send_generation_id         1                           \
        -generation_id_mode         constant                    ]

if {[keylget pim_config_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget pim_config_status log]"
}
set ce_pim_handles    [keylget pim_config_status handle]


################################################################################
# Create CE PIM groups 
################################################################################
set mvpn_source_address $mvpn_source_addr_start
set mvpn_group_address  $mvpn_group_addr_start
set mvpn_rp_address     $mvpn_rp_addr_start
foreach {ce_pim_handle} $ce_pim_handles {
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create                      \
            -num_groups         1                           \
            -ip_addr_start      $mvpn_group_address         \
            -ip_addr_step       $mvpn_group_addr_step       \
            -ip_prefix_len      $mvpn_group_prefix          \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set mvpn_group_pool_handle [keylget pim_config_status handle]
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $ce_pim_handle              \
            -group_pool_handle      $mvpn_group_pool_handle     \
            -rp_ip_addr             $mvpn_rp_address            \
            -rp_ip_addr_step        0.0.0.0                     \
            -join_prune_aggregation_factor 10                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    
    set mvpn_rp_address       [script_increment_ipv4_address \
            $mvpn_rp_address $mvpn_rp_addr_step]
    
    set mvpn_source_address   [script_increment_ipv4_address \
            $mvpn_source_address $mvpn_source_addr_step]
    
    set mvpn_group_address    [script_increment_ipv4_address \
            $mvpn_group_address $mvpn_group_addr_step]
}

################################################################################
# Create CE PIM sources (for bidirectional traffic)
################################################################################
set ce_mcast_source_address $ce_mcast_source_addr_start
set ce_mcast_group_address  $ce_mcast_group_addr_start
set mvpn_rp_address         $mvpn_rp_addr_start
foreach {ce_pim_handle} $ce_pim_handles {
    # Create multicast source
    set pim_config_status [::ixia::emulation_multicast_source_config \
            -mode               create                     \
            -num_sources        1                          \
            -ip_addr_start      $ce_mcast_source_address   \
            -ip_addr_step       $ce_mcast_source_addr_step \
            -ip_prefix_len      $ce_mcast_source_prefix    \
            ]
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set ce_mcast_source_pool_handle [keylget pim_config_status handle]
    
    # Create multicast group
    set pim_config_status [::ixia::emulation_multicast_group_config \
            -mode               create                      \
            -num_groups         1                           \
            -ip_addr_start      $ce_mcast_group_address     \
            -ip_addr_step       $ce_mcast_group_addr_step   \
            -ip_prefix_len      $ce_mcast_group_prefix      \
            ]
    
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    set ce_mcast_group_pool_handle [keylget pim_config_status handle]
    
    # Create PIM Source
    set pim_config_status [::ixia::emulation_pim_group_config   \
            -mode                   create                      \
            -session_handle         $ce_pim_handle              \
            -group_pool_handle      $ce_mcast_group_pool_handle   \
            -source_pool_handle     $ce_mcast_source_pool_handle  \
            -rp_ip_addr             $mvpn_rp_address            \
            -rp_ip_addr_step        0.0.0.0                     \
            -group_pool_mode        register                    \
            -join_prune_aggregation_factor 10                   \
            -wildcard_group                 1                   \
            -s_g_rpt_group                  0                   \
            -rate_control                   1                   \
            -interval                       100                 \
            -join_prune_per_interval        99                  \
            -register_per_interval          101                 \
            -register_stop_per_interval     102                 \
            -register_tx_iteration_gap      6000                \
            -flap_interval                  60                  \
            -spt_switchover                 0                   \
            -source_group_mapping           fully_meshed        \
            -switch_over_interval           5                   \
            -send_null_register             1                   \
            ]
            
    if {[keylget pim_config_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_config_status log]"
    }
    
    set mvpn_rp_address           [script_increment_ipv4_address \
            $mvpn_rp_address $mvpn_rp_addr_step]
    
    set ce_mcast_source_address   [script_increment_ipv4_address \
            $ce_mcast_source_address $ce_mcast_source_addr_step]
    
    set ce_mcast_group_address    [script_increment_ipv4_address \
            $ce_mcast_group_address $ce_mcast_group_addr_step]
}


################################################################################
# Create streams on PE port
################################################################################
set mdt_group_address   $mdt_group_addr_start
set pe_ip_address       $pe_ip_addr_start
set mvpn_source_address $mvpn_source_addr_start
set mvpn_group_address  $mvpn_group_addr_start
for {set i 0} {$i < $pe_count} {incr i} {
    for {set j 0} {$j < $mvrf_count} {incr j} {
        set traffic_status [::ixia::traffic_config           \
                -mode              create                  \
                -port_handle          $pe_port_handle         \
                -frame_size        100                     \
                -l3_protocol          ipv4                       \
                -l4_protocol          gre                     \
                -ip_src_addr          $pe_ip_address          \
                -ip_dst_addr          $mdt_group_address      \
                -gre_version       0                       \
                -inner_protocol    ipv4                    \
                -inner_ip_src_addr $mvpn_source_address    \
                -inner_ip_dst_addr $mvpn_group_address     \
                -rate_percent      10                      \
                -enable_time_stamp 0                       \
                -mac_dst_mode      discovery               ]
        
        if {[keylget traffic_status status] != $::SUCCESS} {
            return "FAIL - $test_name - [keylget traffic_status log]"
        }
        set mvpn_group_address     [script_increment_ipv4_address \
                $mvpn_group_address   $mvpn_group_addr_step]
        
        set mvpn_source_address    [script_increment_ipv4_address \
                $mvpn_source_address $mvpn_source_addr_step]
        
        set mdt_group_address      [script_increment_ipv4_address \
                $mdt_group_address $mdt_group_addr_step]
        
    }
    
    set pe_ip_address  [script_increment_ipv4_address \
            $pe_ip_address $pe_ip_addr_step]
    
    if {$mvrf_unique == 0} {
        set mdt_group_address      $mdt_group_addr_start
        set mvpn_group_address     $mvpn_group_addr_start
        set mvpn_source_address    $mvpn_source_addr_start
        for {set k 0} {$k < $mvpn_num_sources} {incr k} {
            set mvpn_source_address   [script_increment_ipv4_net \
                    $mvpn_source_address $mvpn_source_prefix]
        }
    }
}

################################################################################
# Create streams on CE port
################################################################################
for {set i 0} {$i < $pe_count} {incr i} {
    set ce_mcast_group_address     $ce_mcast_group_addr_start
    set ce_mcast_source_address    $ce_mcast_source_addr_start
    set ce_vlan_id                 $ce_vlan_id_start
    for {set j 0} {$j < $mvrf_count} {incr j} {
        set traffic_status [::ixia::traffic_config           \
                -mode              create                  \
                -port_handle          $ce_port_handle         \
                -frame_size        100                     \
                -l3_protocol          ipv4                       \
                -ip_src_addr          $ce_mcast_source_address    \
                -ip_dst_addr          $ce_mcast_group_address     \
                -rate_percent      10                      \
                -enable_time_stamp 0                       \
                -mac_dst_mode      discovery               \
                -vlan_id           $ce_vlan_id             \
                -vlan_id_mode      fixed                   ]
        
        if {[keylget traffic_status status] != $::SUCCESS} {
            return "FAIL - $test_name - [keylget traffic_status log]"
        }
        
        incr ce_vlan_id $ce_vlan_id_step
        
        set ce_mcast_group_address     [script_increment_ipv4_address \
                $ce_mcast_group_address   $ce_mcast_group_addr_step]
        
        set ce_mcast_source_address    [script_increment_ipv4_address \
                $ce_mcast_source_address $ce_mcast_source_addr_step]
        
    }
}

################################################################################
# Send ARP Request
################################################################################
set interface_status [::ixia::interface_config \
        -port_handle     $port_handle          \
        -arp_send_req    1                     ]
if {[keylget interface_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget interface_status log]"
}

# Start BGP protocol
set bgp_control_status [::ixia::emulation_bgp_control  \
        -port_handle $pe_port_handle \
        -mode        start           ]
if {[keylget bgp_control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget bgp_control_status log]"
}
# Set up the bgp stats on the handles after starting the protocol
foreach {bgp_neighbor} $pe_bgp_handles {
    set bgp_control_status [::ixia::emulation_bgp_control  \
            -handle $bgp_neighbor \
            -mode   statistic     ]
    if {[keylget bgp_control_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget bgp_control_status log]"
    }
}

# Start ISIS protocol
set isis_emulation_status [::ixia::emulation_isis_control \
        -handle      $provider_isis_handle              \
        -mode        start                              ]

if {[keylget isis_emulation_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget isis_emulation_status log]"
}

# Start RSVP protocol
set rsvp_control_status [::ixia::emulation_rsvp_control \
        -port_handle    $pe_port_handle                 \
        -mode           start                           ]

if {[keylget rsvp_control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget rsvp_control_status log]"
}

# Start PIM protocol
set pim_control_status [::ixia::emulation_pim_control  \
        -handle                $provider_pim_handle  \
        -mode                  start                 ]

if {[keylget pim_control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget pim_control_status log]"
}

foreach {pim_neighbor} $pe_pim_handles {
    set pim_control_status [::ixia::emulation_pim_control \
            -handle                $pim_neighbor        \
            -mode                  start                ]
    
    if {[keylget pim_control_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_control_status log]"
    }
}

foreach {pim_neighbor} $ce_pim_handles {
    set pim_control_status [::ixia::emulation_pim_control \
            -handle                $pim_neighbor        \
            -mode                  start                ]
    
    if {[keylget pim_control_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget pim_control_status log]"
    }
}


# Wait 100 seconds for BGP and ISIS sessions to establish
after 100000

set port_handle [concat $pe_port_handle $ce_port_handle]

# Clear all statistics on ports
set traffic_status [::ixia::traffic_control \
        -action      clear_stats          \
        -port_handle $port_handle         ]
if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

# Start traffic on ports
set traffic_status [::ixia::traffic_control \
        -action      run                  \
        -port_handle $port_handle         ]
if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

# Procedure to print stats
proc post_stats {port_handle label key_list stat_key {stream ""}} {
    puts -nonewline [format "%-30s" $label]
    
    foreach port $port_handle {
        if {$stream != ""} {
            set key $port.stream.$stream.$stat_key
        } else {
            set key $port.$stat_key
        }
        
        if {[llength [keylget key_list $key]] > 1} {
            puts -nonewline "[format "%-16s" N/A]"
        } else  {
            puts -nonewline "[format "%-16s" [keylget key_list $key]]"
        }
    }
    puts ""
}

# Wait while sending traffic
after 10000

# Stop traffic on the ports
set traffic_stop_status [::ixia::traffic_control \
        -port_handle $port_handle              \
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

puts "\n************************* STATISTICS **************************"
puts -nonewline "[format "%-30s" " "]"
foreach port $port_handle {
    puts -nonewline "[format "%-16s" $port]"
}
puts ""
puts -nonewline "[format "%-30s" " "]"
foreach port $port_handle {
    puts -nonewline "[format "%-16s" "-----"]"
}
puts ""


post_stats $port_handle "Elapsed Time"   $aggregate_stats \
        aggregate.tx.elapsed_time

post_stats $port_handle "Packets Tx"     $aggregate_stats \
        aggregate.tx.pkt_count

post_stats $port_handle "Bytes Tx"       $aggregate_stats \
        aggregate.tx.pkt_byte_count

post_stats $port_handle "Bits Tx"        $aggregate_stats \
        aggregate.tx.pkt_bit_count

post_stats $port_handle "Packets Rx"     $aggregate_stats \
        aggregate.rx.pkt_count

post_stats $port_handle "Collisions"     $aggregate_stats \
        aggregate.rx.collisions_count

post_stats $port_handle "Dribble Errors" $aggregate_stats \
        aggregate.rx.dribble_errors_count

post_stats $port_handle "CRCs"           $aggregate_stats \
        aggregate.rx.crc_errors_count

post_stats $port_handle "Oversizes"      $aggregate_stats \
        aggregate.rx.oversize_count

post_stats $port_handle "Undersizes"     $aggregate_stats \
        aggregate.rx.undersize_count

post_stats $port_handle "Data Integrity Frames" $aggregate_stats \
        aggregate.rx.data_int_frames_count

post_stats $port_handle "Data Integrity Error"  $aggregate_stats \
        aggregate.rx.data_int_errors_count

puts "***************************************************************\n"

return "SUCCESS - $test_name - [clock format [clock seconds]]"