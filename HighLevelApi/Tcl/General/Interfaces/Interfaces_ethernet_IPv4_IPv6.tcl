################################################################################
# Version 1.0    $Revision: 2 $
# $Author: Lavinia Raicea $
#
#    Copyright � 1997 - 2005 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    17/6-2005 Lavinia Raicea
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
###############################################################################

################################################################################
#                                                                              #
# Description:                                                                 #
#    This sample creates three IPv4 addresses and two IPv6 addresses on the    #
#    same interface.                                                           #
#                                                                              #
# Module:                                                                      #
#    The sample was tested on a LM100TXS8 module.                              #
#                                                                              #
################################################################################

package require Ixia

set test_name [info script]

set chassisIP 127.0.0.1
set port_list [list 10/1]

# Connect to the chassis, reset to factory defaults and take ownership
set connect_status [::ixia::connect \
        -reset                    \
        -device    $chassisIP     \
        -port_list $port_list     \
        -username  ixiaApiUser    ]
if {[keylget connect_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget connect_status log]"
}

set port_handle [keylget connect_status port_handle.$chassisIP.$port_list]

########################################
# Configure interface in the test      #
# IPv4                                 #
########################################
set interface_status [::ixia::interface_config \
        -port_handle        [list $port_handle $port_handle $port_handle]     \
        -intf_ip_addr       [list 12.1.3.2 13.1.3.2 14.1.3.2]                 \
        -gateway            [list 12.1.3.1 13.1.3.1 14.1.3.1]                 \
        -netmask            255.255.255.0                                     \
        -ipv6_intf_addr     [list 32:32:32:32:1:1:1:1 {} 34:34:34:34:1:1:1:1] \
        -ipv6_prefix_length 80               \
        -autonegotiation    1                \
        -src_mac_addr       0000.0005.0001   \
        -op_mode            normal           \
        -vlan               [list 1 0 1]     \
        -vlan_id            [list 102 0 104] \
        -vlan_user_priority 7                \
        -duplex             auto             \
        -speed              auto             \
        -intf_mode          ethernet         ]
        
if {[keylget interface_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget interface_status log]"
}

return "SUCCESS - $test_name - [clock format [clock seconds]]"
