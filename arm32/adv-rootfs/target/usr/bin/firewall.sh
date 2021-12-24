#!/bin/sh

if [ -z "$1" ] ; then
    echo "Usage: $0 config_path|stop"
    echo "Example: $0 /etc/firewall"
    echo "Example: $0 stop"
    exit 1
fi

if [ "$1" != "stop" ]; then
    CONFIG_PATH=$1
fi

IPT=/usr/sbin/iptables
MOD=/sbin/modprobe
CTL=/sbin/sysctl

LO_IFACE="lo"
LO_IP="127.0.0.1"

$MOD ip_tables 
$MOD ip_conntrack 
$MOD ipt_REJECT
$MOD ipt_LOG 
$MOD ipt_iprange
$MOD xt_tcpudp 
$MOD xt_state 
$MOD xt_multiport 

$CTL -w net.ipv4.ip_forward=1 > /dev/null 2>&1
#$CTL -w net.ipv4.ip_default_ttl=128  > /dev/null 2>&1 
#$CTL -w net.ipv4.icmp_echo_ignore_all=1 > /dev/null 2>&1
#$CTL -w net.ipv4.icmp_echo_ignore_broadcasts=1 > /dev/null 2>&1

echo "Flushing Tables ..."

# Reset Default Policies
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -P POSTROUTING ACCEPT
$IPT -t nat -P OUTPUT ACCEPT
$IPT -t mangle -P PREROUTING ACCEPT
$IPT -t mangle -P OUTPUT ACCEPT

# Flush all rules
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F

# Erase all non-default chains
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

iptables-restore < /etc/iptables.up.rules
if [ "$1" = "stop" ]; then
    echo "Firewall completely flushed!  Now running with no firewall."
    exit 0
fi

# Set Policies

$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP
$IPT -A INPUT -m state --state ESTABLISHED -j ACCEPT

# INPUT Chain
# Localhost
$IPT -A INPUT -p ALL -i $LO_IFACE -j ACCEPT

PORT_WHITE_LIST="$CONFIG_PATH/port_white.lst"
PORT_BLACK_LIST="$CONFIG_PATH/port_black.lst"

if [ -f $PORT_WHITE_LIST ]; then
cat $PORT_WHITE_LIST | grep -v "#" | while read i
do
    PORT_PROTO=$i
    PORT=`echo $PORT_PROTO|awk -F "|" '{print $1}'`
    PROTO=`echo $PORT_PROTO|awk -F "|" '{print $2}'`
    IFACE=`echo $PORT_PROTO|awk -F "|" '{print $3}'`
    IP=`echo $PORT_PROTO|awk -F "|" '{print $4}'`

    if [[ $PORT =~ "," ]] || [[ $PORT =~ ":" ]]; then
	PORT_OPT="--dports $PORT"
	MATCH_OPT="-m multiport"	
    elif [[ $PORT = "all" ]]; then
	PORT_OPT=""
    else
	PORT_OPT="--dport $PORT"
	MATCH_OPT="-m $PROTO"
    fi
	
    if [ $PROTO = "all" ]; then
        if [[ $PORT =~ "," ]] || [[ $PORT =~ ":" ]]; then
            PROTO_OPT="-p tcp"
        else
            PROTO_OPT="-p tcp"
            MATCH_OPT=""
        fi
    else                         
        if [[ $PORT =~ "," ]] || [[ $PORT =~ ":" ]]; then
            PROTO_OPT="-p $PROTO"
        else
            PROTO_OPT="-p $PROTO"
            MATCH_OPT="-m $PROTO"
        fi
    fi

    if [[ $IFACE = "" ]] || [[ $IFACE = "all" ]]; then
        IFACE_OPT=""
    else
	IFACE_OPT="-i $IFACE"
    fi

    if [[ $IP = "" ]] || [[ $IP = "all" ]]; then
        IP_OPT=""
    else
        IP_VAR=`echo $IP | awk '{print $1}'`
        if [[ $IP_VAR = "iprange" ]]; then
	    IP_OPT="-m $IP"
        else
	    IP_OPT="-s $IP"
        fi
    fi
    $IPT -I INPUT $PROTO_OPT $MATCH_OPT $PORT_OPT $IFACE_OPT $IP_OPT -j ACCEPT
done
fi

if [ -f $PORT_BLACK_LIST ]; then
cat $PORT_BLACK_LIST | grep -v "#" | while read i
do
    PORT_PROTO=$i
    PORT=`echo $PORT_PROTO|awk -F "|" '{print $1}'`
    PROTO=`echo $PORT_PROTO|awk -F "|" '{print $2}'`
    IFACE=`echo $PORT_PROTO|awk -F "|" '{print $3}'`
    IP=`echo $PORT_PROTO|awk -F "|" '{print $4}'`

    if [[ $PORT =~ "," ]] || [[ $PORT =~ ":" ]]; then
	PORT_OPT="--dports $PORT"
	MATCH_OPT="-m multiport"	
    elif [[ $PORT = "all" ]]; then
	PORT_OPT=""
    else
	PORT_OPT="--dport $PORT"
	MATCH_OPT="-m $PROTO"
    fi
	
    if [ $PROTO = "all" ]; then
        if [[ $PORT =~ "," ]] || [[ $PORT =~ ":" ]]; then
            PROTO_OPT="-p tcp"
        else
            PROTO_OPT="-p tcp"
            MATCH_OPT=""
        fi
    else                         
        if [[ $PORT =~ "," ]] || [[ $PORT =~ ":" ]]; then
            PROTO_OPT="-p $PROTO"
        else
            PROTO_OPT="-p $PROTO"
            MATCH_OPT="-m $PROTO"
        fi
    fi

    if [[ $IFACE = "" ]] || [[ $IFACE = "all" ]]; then
        IFACE_OPT=""
    else
	IFACE_OPT="-i $IFACE"
    fi

    if [[ $IP = "" ]] || [[ $IP = "all" ]]; then
        IP_OPT=""
    else
        IP_VAR=`echo $IP | awk '{print $1}'`
        if [[ $IP_VAR = "iprange" ]]; then
	    IP_OPT="-m $IP"
        else
	    IP_OPT="-s $IP"
        fi
    fi
    $IPT -I INPUT $PROTO_OPT $MATCH_OPT $PORT_OPT $IFACE_OPT $IP_OPT -j DROP
done
fi

# OUTPUT Chain
# Invalid icmp packets need to be dropped
$IPT -A OUTPUT -m state -p icmp --state INVALID -j DROP

# Localhost
$IPT -A OUTPUT -p ALL -s $LO_IP -j ACCEPT
$IPT -A OUTPUT -p ALL -o $LO_IFACE -j ACCEPT

# To internet
$IPT -A OUTPUT -p ALL -j ACCEPT

exit 0

