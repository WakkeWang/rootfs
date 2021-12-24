set -e

if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "Wrong arguments for ifplugd" > /dev/stderr
	exit 1
fi

if [ "$2" = "up" ] 
then
	if [ "$1" != "wlan0" ];then
		if [ -x $TAGLINK_PATH/util/ipcheck ]; then
			ifup -f $1 || $TAGLINK_PATH/util/ipcheck $1
		else
			ifup -f $1 
		fi
	fi

	if [ -x $TAGLINK_PATH/util/fixroute ]; then
		$TAGLINK_PATH/util/fixroute
	fi
fi

if [ "$2" = "down" ] 
then 
	ifdown $1
	ip -4 addr flush dev $1
	if [ -x $TAGLINK_PATH/util/fixroute ]; then
		$TAGLINK_PATH/util/fixroute
	fi
fi

exit 1

