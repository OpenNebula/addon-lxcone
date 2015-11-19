#!/bin/bash

# -------------------------------------------------------------------------- #
# Copyright 2002-2015, OpenNebula Project (OpenNebula.org), C12G Labs        #
# 									     #
# Authors: Sergio Vega Gutiérrez          sergiojvg92@gmail.com		     #
#	   José Manuel de la Fé Herrero   jmdelafe92@gmail.com               #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

##############################################################################
#				   CPU					     #
##############################################################################

pre_cant_cpu=$(nproc)
cant_cpu=$(($pre_cant_cpu * 100))
pre_cpu_speed=$(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^ *//' | sed -e 's/$/"/' | cut -d '@' -f2 | cut -b 2-5)
cpu_speed=`awk "BEGIN {print $pre_cpu_speed * 1000000000}"`
pre_cpu_iddle=$(top -n 1 -b | grep "Cpu" | awk '{print $8}')
cpu_iddle=`awk "BEGIN {print $pre_cpu_iddle * $pre_cant_cpu}"`
cpu_used=`awk "BEGIN {print (100-$pre_cpu_iddle)*$pre_cant_cpu}"`


##############################################################################
#			         MEMORY					     #
##############################################################################

total_RAM=$(free | awk ' /^Mem/ { print $2 }')
used_RAM=$(free | awk '/buffers\/cache/ { print $3 }')
free_RAM=$(free | awk '/buffers\/cache/ { print $4 }')


##############################################################################
#			       NETWORKING				     #
##############################################################################

#rNET_TX=`more /sys/class/net/br0/statistics/tx_bytes`
#rNET_RX=`more /sys/class/net/br0/statistics/rx_bytes`
#let "NET_RX = ${rNET_RX}"
#let "NET_TX = ${rNET_TX}"

read _NETRX _NETTX <<< `/sbin/ifconfig br0 | grep "RX bytes" | awk ' { print $2 " " $6 } '` 

NETTX=${_NETRX/*:}
NETRX=${_NETTX/*:}

echo HYPERVISOR=lxc
echo TOTALCPU=$cant_cpu
echo CPUSPEED=$cpu_speed
echo TOTALMEMORY=$total_RAM
echo USEDMEMORY=$used_RAM
echo FREEMEMORY=$free_RAM
echo FREECPU=$cpu_iddle
echo USEDCPU=$cpu_used
echo NETRX=$NETRX
echo NETTX=$NETTX
echo ARCH=`uname -m`
echo HOSTNAME=`uname -n`
/var/lib/one/remotes/vmm/lxc/poll
