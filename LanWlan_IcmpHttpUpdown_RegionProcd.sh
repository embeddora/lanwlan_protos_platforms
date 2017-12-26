#!/bin/bash 
#
# Copyright (c) 2018 [n/a] info@embeddora.com All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#        * Redistributions of source code must retain the above copyright
#          notice, this list of conditions and the following disclaimer.
#        * Redistributions in binary form must reproduce the above copyright
#          notice, this list of conditions and the following disclaimer in the
#          documentation and/or other materials provided with the distribution.
#        * Neither the name of The Linux Foundation nor
#          the names of its contributors may be used to endorse or promote
#          products derived from this software without specific prior written
#          permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.    IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Abstract: multi-proto multi-platform time measurements
#


. $0.lib
#echo "names are: 0 $0 1 $1 2 $2 3 $3    4 $4 5 $5 6 $6     7 $7 8 $8 9 $9 "

lan_http()
{
	# Connect to DUT/CPE
	connect_wire

	# Ask remove IGMP peer to give instant responce to first request ot PING command
	check_link

	# Ask HTTP webserver for at least 1 correct responce
	kick_webserver
}


lan_icmp()
{
	# Connect to DUT/CPE
	connect_wire

	# Ask remove IGMP peer to give instant responce to first request ot PING command
	check_link
}

# Subject for removal. Kept for code changes back tracking
lan_http_procd()
{
	# Execute <connect_wire>, <check_link>, <kick_webserver> for <TouchP5-PROCD>
	lan_http

} # lan_http_procd()

# Subject for removal. Kept for code changes back tracking
lan_http_region()
{
	# Execute <connect_wire>, <check_link>, <kick_webserver> for <TouchP5-REGION>
	lan_http

} # lan_http_region()

# Subject for removal. Kept for code changes back tracking
lan_icmp_procd()
{
	# Execute <connect_wire>, <check_link> for <TouchP5-PROCD>
	lan_icmp

} # lan_icmp_procd()

# Function to reboot (via LAN) DUT/CPE on boot-up completion, repeatedly
lan_updown()
{
# Cycle counter
REPEATS=$REPETITIONS

	# Don't del This echo contains <REPEATS> - divider for computation arithmetical mean (a.k.a. average boot time)
	echo "[$0] Doing $REPEATS bootup-shutdown loops"

	# As long as amountg of <REPEATS> is not exhausted...
	while [ "$REPEATS" -gt 0 ]

	#... do repeat the next bunch of operations
	do
		# Tip: rare case a hardcoded TMO is allowed. Because at this moment the DUT/CPE is either in U-Boot either runs first instr's of Kernel. Uncomment: sleep 5 		

		echo "[$0] Loop $REPEATS"

		# Wait for DUT/CPE to boot up LAN interfaces
		lan_icmp

		# Tip: using <curl> instead of <send_death_packet>? Terminate <curl> started on previous loop. Uncomment: killall curl > /dev/null 2>&1

		# Tip: don't have <curl>? Use 'Mozilla Firefox': firefox -url 192.168.0.1:88 || killall -q firefox || ... 

		# Tip: exiting from <send_death_packet> on TMO implies us to be sure the AUX-server has been started. Rework server side and uncomment: ensure_aux_started

		# Send a death-packet to DUT/CPE to AUX. web-server vial LAN
		send_death_packet

		# Drop an updated status to STDOUT
		echo "HAVE JUST REBOOTED THE $TARGET_IPV4"

		# Compute 'REPEATS--'
		let "REPEATS -= DECREMENT"
	done
}

# Subject for removal 
lan_icmp_region()
{
	# Execute <connect_wire>, <check_link> for <TouchP5-REGION>
	lan_icmp

} # lan_icmp_region()

wlan_icmp_procd()
{
	# Connect to DUT/CPE
	connect_radio

	# Ensure the link has adopted by the local system before polling anything else
	wait_link

	# Assign DHCP address ande ask remote ICMP peer to give instant responce to first request ot PING command
	check_air

} # wlan_icmp_procd()

wlan_icmp_region()
{
	# Connect to DUT/CPE
	connect_radio

	# Ensure the link has adopted by the local system before polling HTTP server
	wait_link

	################################  DOUBLED INIT STARTS HERE

	# Terminate previously started processes once we're interrupted this script eaelier with CTRL+C, for instance
	kill $(ps aux | grep -E 'dhclient' | awk '{print $2}') > /dev/null 2>&1

	# Connect to DUT/CPE
	connect_radio

	# Ensure the link has adopted by the local system before polling HTTP server
	wait_link

	################################ DOUBLED INIT FINISHES HERE

	# Assign DHCP address ande ask remote ICMP peer to give instant responce to first request ot PING command
	check_air

} # wlan_icmp_region()

wlan_http_procd()
{
	# Connect to DUT/CPE
	connect_radio

	# Ensure the link has adopted by the local system before polling HTTP server
	wait_link

	#TODO: inspect if needed: check_air

	# Ask HTTP webserver for at least 1 correct responce
	poll_webserver 

} # wlan_http_procd()

wlan_http_region()
{

	# Connect to DUT/CPE
	connect_radio

	# Ensure the link has adopted by the local system before polling HTTP server
	wait_link

	# DOUBLED INIT STARTS HERE

	# Terminate previously started processes once we're interrupted this script eaelier with CTRL+C, or sort of that
	kill $(ps aux | grep -E 'dhclient' | awk '{print $2}') > /dev/null 2>&1

	# Connect to DUT/CPE
	connect_radio

	# Ensure the link has adopted by the local system before polling HTTP server
	wait_link

	# DOUBLED INIT FINISHES HERE

	#TODO: inspect if needed: check_air

	# Ask HTTP webserver for at least 1 correct responce
	poll_webserver 

} # wlan_http_region()


# Function to reboot (via WLAN) DUT/CPE on boot-up completion, repeatedly
wlan_updown()
{
# Cycle counter
REPEATS=$REPETITIONS

	# Don't del This echo contains <REPEATS> - divider for computation arithmetical mean (a.k.a. average boot time)
	echo "[$0] Doing $REPEATS bootup-shutdown loops"

	# As long as amountg of <REPEATS> is not exhausted...
	while [ "$REPEATS" -gt 0 ]

	#... do repeat the next bunch of operations
	do
		echo "[$0] Loop $REPEATS"

		# Wait for DUT/CPE to boot up WLAN interfaces
		if [ "$TARGET" = "procd" ]
		then
				wlan_icmp_procd

		else
				wlan_icmp_region
		fi


		# Send a death-packet to DUT/CPE to AUX. web-server vial WLAN
		send_death_packet

		# Drop an updated status to STDOUT
		echo "HAVE JUST REBOOTED THE $TARGET_IPV4"

		# Compute 'REPEATS--'
		let "REPEATS -= DECREMENT"
	done
}


# Wellknown user on most Linux's
ROOTNAME=root

# Also 'whoami', and many other things 
USERNAME=`id -nu`

# Ensure the access level is sufficient
if [ "$ROOTNAME" != "$USERNAME" ]
then

	# Drop here as much info as only can - in 50% cases the users will aim to start this routine from under non-root, presumably.
	echo  "Since '$0' is supposed to run such system utilities as 'ifconfig', 'iwconfig', etc, it should be started from under 'root' user. And '$USERNAME' is the one. Exiting..."

	# Hope that somebody someday will check this
	exit -1
fi

MEDIA="$1"

# Once needed, initialize with default value, which is one of two: "lan", "wlan"
[ -z "$MEDIA" ] && MEDIA="wlan"

PROTO="$2"

# Once needed, initialize with default value, which is one of two: "icmp", "http" (TODO: maybe better is "ping", "web"?)
[ -z "$PROTO" ] && PROTO="http"

TARGET="$3"

# Once needed, initialize with default value, which is one of two: "procd", "region"
[ -z "$TARGET" ] && TARGET="procd"

echo "[$0] [START] media: $MEDIA		proto: $PROTO		target: $TARGET "

# To prevent others indrude into our task; TODO: compute correct interval
flock -w $TMO $0.lck  -c which

FNAME=$MEDIA.$PROTO.$TARGET.time
CONFNAME=$MEDIA.$PROTO.$TARGET.conf

CTIME_ENTRIES=($($'uptime')) && echo "$0 ($MEDIA, $PROTO, $TARGET)	started at ${CTIME_ENTRIES[0]}" >./$FNAME

STARTTIME=`awk '{print $1}' /proc/uptime`

# Terminate previously started process(es) 
kill $(ps aux | grep -E 'dhclient' | awk '{print $2}')  > /dev/null 2>&1

case $MEDIA in
	"lan" )
		case $PROTO in

			"updown" )
				case $TARGET in
					"procd" | "region" )
						lan_updown "$*"
					;;

					* )
						echo "ERROR: incorrect target system name $TARGET to test system responce via protocol '$PROTO' over '$MEDIA'"
						exit -8
					;;
				esac
					
			;;

			"http" )
				case $TARGET in
					"procd" | "region")
						lan_http "$*"
					;;


					* )
						echo "ERROR: incorrect target system name $TARGET to test system responce via protocol '$PROTO' over '$MEDIA'"
						exit -7
					;;
				esac
					
			;;

			"icmp" )
				case $TARGET in
					"procd" | "region")
						lan_icmp "$*"
					;;


					* )
						echo "ERROR: incorrect target system name $TARGET to test system responce via protocol '$PROTO' over '$MEDIA'"
						exit -6
					;;
				esac
			;;

			* ) 	
				echo "ERROR: no implementation to test target system responce via protocol '$PROTO' over '$MEDIA'"
				exit -5
			;;	 
		esac
	;;

	"wlan" ) 
		case $PROTO in

			"updown" )
				case $TARGET in
					"procd" | "region" )
						wlan_updown "$*"
					;;

					* )
						echo "ERROR: incorrect target system name $TARGET to test system responce via protocol '$PROTO' over '$MEDIA'"
						exit -4
					;;
				esac
					
			;;

			"http" )
				case $TARGET in
					"procd" )
						wlan_http_procd "$*"
					;;

					"region" )
						wlan_http_region "$*"						
					;;

					* )
						echo "ERROR: incorrect target system name $TARGET to test system responce via protocol '$PROTO' over '$MEDIA'"
						exit -3
					;;					
				esac
			;;

			"icmp" )
				case $TARGET in
					"procd" )
						wlan_icmp_procd "$*"
					;;

					"region" )
						wlan_icmp_region "$*"						
					;;

					* )
						echo "ERROR: incorrect target system name $TARGET to test system responce via protocol '$PROTO' over '$MEDIA'"
						exit -2
					;;
				esac
			;;

			* ) 	
				echo "ERROR: no implementation to test target system responce via protocol '$PROTO' over '$MEDIA'"
				exit -1
			;;	 
		esac
	;;


	* ) 
		echo "ERROR: no such network media '$MEDIA'"
		exit -1
	;;
esac

# Now everyone may do what he wants (tip: 'which' inserted to satisfy '-c' parameter, needed to provide filename instead of fdescr.)
flock -u $0.lck -c which

CTIME_ENTRIES=($($'uptime')) && echo "$0 ($MEDIA, $PROTO, $TARGET)	finished at ${CTIME_ENTRIES[0]}" >> ./$FNAME

ENDTIME=`awk '{print $1}' /proc/uptime`

TIMEDIFF=$(echo "scale=9; $ENDTIME-$STARTTIME" | bc)

echo "[$0] [END] operation done in $TIMEDIFF seconds"

if [ "$PROTO" = "updown" ]
then
	AVERAGE=$(echo "scale=9; $TIMEDIFF/$REPETITIONS" | bc)

	echo "[$0] [AVG] Average boot time: $AVERAGE"
fi

# Clean after ourselves
rm -f ./*.lck ./*.conf ./*.log ./*.LOG

# Right place to go out; any other can leave in process tree not terminated processes/daemons
exit 0
