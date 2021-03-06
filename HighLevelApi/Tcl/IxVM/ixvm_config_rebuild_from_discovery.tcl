#################################################################################
# Version 1    $Revision: 1 $
# $Author: RCsutak $
#
#    Copyright � 1997 - 2014 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    11-20-2014 RCsutak - created sample
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
#   This sample connects to an IxNetwork client and, using the HL API,		   #	
#	deletes all cards present on a virtual chassis and rebuilds a topology 	   #	
#	from the devices discovered over the network.							   #
#                                                                              #
################################################################################

if {[catch {package require Ixia} retCode]} {
    puts "FAIL - [info script] - $retCode"
    return 0
}

################################################################################
# General script variables
################################################################################
set chassis_ip              10.205.23.219
set ixnetwork_tcl_server    localhost
set test_name               [info script]
set test_name_folder        [file dirname $test_name]
set virtual_chassis			10.205.23.219

################################################################################
# START - Connect to IxN client
################################################################################

set res [ixiangpf::connect                          \
	-reset											\
	-vport_count			1						\
    -ixnetwork_tcl_server 	$ixnetwork_tcl_server   \
]
if {[keylget res status] != $::SUCCESS} {
   puts "Connect failed: $res"
   return 0
}

puts "Deleting all cards from chassis ...\n"
set clear_chassis [::ixiangpf::ixvm_config				\
	-mode 				delete_all						\
	-virtual_chassis	$virtual_chassis				\
]
if {[keylget clear_chassis status] != $::SUCCESS} {
   puts "Delete failed: $clear_chassis"
   return 0
}



puts "Rebuilding topology from discovered devices ...\n"

set rebuild [::ixiangpf::ixvm_config			 		\
	-mode						create					\
	-virtual_chassis 			$chassis_ip				\
	-rediscover					1						\
	-rebuild_from_discovery		1						\
]
if {[keylget rebuild status] != $::SUCCESS} {
   puts "Card failed: $rebuild"
   return 0
}

puts "Script has finished SUCCESSFULLY!\n"
return 1


	