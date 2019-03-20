# start dhclient daemon script
#
# check if we have USE_DHCLIENT=y, if not then we run 60/62 scripts
[[ -z "$USE_DHCLIENT"  ]] && return

# with USE_STATIC_NETWORKING no networking setup via DHCP must happen
# see default.conf: USE_STATIC_NETWORKING overrules USE_DHCLIENT
test "$USE_STATIC_NETWORKING" && return

# if 'noip' is gicen on boot prompt then skip dhcp start-up
if [[ -e /proc/cmdline ]] ; then
    if grep -q 'noip' /proc/cmdline ; then
        return
    fi
fi

echo "Attempting to start the DHCP client daemon"

# To be sure that network is properly initialized (get_device_by_hwaddr sees network interfaces)
sleep 5

# Source the network related functions:
source /etc/scripts/dhcp-setup-functions.sh

# Need to find the devices and their HWADDR (avoid local and virtual devices)
for DEVICE in `get_device_by_hwaddr` ; do
        case $DEVICE in
		(lo|pan*|sit*|tun*|tap*|vboxnet*|vmnet*|virt*|vif*) continue ;; # skip all kind of internal devices
        esac
        HWADDR=`get_hwaddr $DEVICE`

	if [ -n "$HWADDR" ]; then
		HWADDR=$(echo $HWADDR | awk '{ print toupper($0) }')
	    DEVICE=$(get_device_by_hwaddr $HWADDR)
	fi
	[ -z "$DEVICETYPE" ] && DEVICETYPE=$(echo ${DEVICE} | sed "s/[0-9]*$//")
	[ -z "$REALDEVICE" -a -n "$PARENTDEVICE" ] && REALDEVICE=$PARENTDEVICE
	[ -z "$REALDEVICE" ] && REALDEVICE=${DEVICE%%:*}
	if [ "${DEVICE}" != "${REALDEVICE}" ]; then
		ISALIAS=yes
	else
		ISALIAS=no
	fi

	# IPv4 DHCP clients
	case $DHCLIENT_BIN in
		(dhclient)
			dhclient -lf /var/lib/dhclient/dhclient.leases.${DEVICE} -pf /var/run/dhclient.${DEVICE}.pid -cf /etc/dhclient.conf ${DEVICE}
		;;
		(dhcpcd)
			dhcpcd ${DEVICE}
		;;
	esac

	# IPv6 DHCP clients
	case $DHCLIENT6_BIN in
		(dhclient6)
			dhclient6 -lf /var/lib/dhclient/dhclient.leases.${DEVICE} -pf /var/run/dhclient.${DEVICE}.pid -cf /etc/dhclient.conf ${DEVICE}
		;;
		(dhcp6c)
			dhcp6c  ${DEVICE}
		;;
	esac
done
