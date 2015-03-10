#!/bin/sh
while true; do

	# Clean up previously running apps, gracefully at first then harshly
	killall -TERM chromium 2>/dev/null;
	killall -TERM matchbox-window-manager 2>/dev/null;
	sleep 2;
	killall -9 chromium 2>/dev/null;
	killall -9 matchbox-window-manager 2>/dev/null;

	# Clean out existing profile information
	rm -rf /home/pi/.cache;
	rm -rf /home/pi/.config;
	rm -rf /home/pi/.pki;

	# Generate the bare minimum to keep Chromium happy!
	mkdir -p /home/pi/.config/chromium/Default
	sqlite3 /home/pi/.config/chromium/Default/Web\ Data "CREATE TABLE meta(key LONGVARCHAR NOT NULL UNIQUE PRIMARY KEY, value LONGVARCHAR); INSERT INTO meta VALUES('version','46'); CREATE TABLE keywords (foo INTEGER);";

	# Disable DPMS / Screen blanking
	xset -dpms
	xset s off

	# Reset the framebuffer's colour-depth
	fbset -depth $( cat /sys/module/*fb*/parameters/fbdepth );

	# Hide the cursor (move it to the bottom-right, comment out if you want mouse interaction)
	xwit -root -warp $( cat /sys/module/*fb*/parameters/fbwidth ) $( cat /sys/module/*fb*/parameters/fbheight )

	# Start the window manager (remove "-use_cursor no" if you actually want mouse interaction)
	matchbox-window-manager -use_titlebar no -use_cursor no &

	#Concerto Player Configuration
	URL=`cat /proc/cmdline | perl -ne 'print "$1\n" if /concerto.url=(\S+)/'`
	if [ -z $URL ]; then
		URL=http://localhost:4567/screen
	fi

	# add custom xrandr commands to this file
	if [ -x /lib/live/mount/medium/xrandr.sh ]; then
	        /lib/live/mount/medium/xrandr.sh
	fi

	ROTATE=`cat /proc/cmdline | perl -ne 'print "$1\n" if /concerto.rotate=(\S+)/'`
	if [ -n $ROTATE ]; then
		xrandr -o $ROTATE
	fi

	MAC_DETECT=`cat /proc/cmdline | perl -ne 'print "1\n" if /concerto.mac_detect/'`
	if [ -n $MAC_DETECT ]; then
		MAC=`/sbin/ifconfig eth0 | perl -ne 'print "$1\n" if /(([0-9a-f]{2}:){5}[0-9a-f]{2})/'`
		URL=${URL}?mac=$MAC
	fi
	# hide the mouse pointer
	unclutter &

	# disable power-management and screen blanking
	xset -dpms
	xset s off
	# wait until the local http server is available
	until wget -q http://localhost:4567
	do
	  sleep 2
	done

	# Start the browser (See http://peter.sh/experiments/chromium-command-line-switches/)
	chromium  --app=$URL

done;