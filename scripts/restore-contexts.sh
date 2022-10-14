#!/bin/bash
#########################################################
#														#
#			SELinux Springboot policy module			#
#														#
#	Restore fcontext script:							#
#		This script restores SELinux fcontexts.			#
#														#
#    https://github.com/hubertqc/selinux_springboot		#
#														#
#########################################################

typset -i RC
RC=0

if selinuxenabled
then
  restorecon -RFi /{opt,srv}/springboot 
  restorecon -RFi /{lib,etc}/systemd/system/springboot*
  restorecon -RFi /var/{lib,log,run,tmp}/springboot
else
	echo "SElinux is not enabled, unable to restore fcontext."
	RC=1
fi

exit $RC