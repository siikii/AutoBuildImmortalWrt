#!/bin/sh
# 99-custom.sh is the script that runs at ImmortalWrt's first boot. It is located in /etc/uci-defaults/99-custom.sh
# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE

# Setting firewall rules, so that user can access WebUI after first boot
uci set firewall.@zone[1].input='ACCEPT'

# Resolve time server IP address
uci add dhcp domain
uci set "dhcp.@domain[-1].name=time.android.com"
uci set "dhcp.@domain[-1].ip=203.107.6.88"

# Check if pppoe-settings exists. The file is created in the build.sh script.
SETTINGS_FILE="/etc/config/pppoe-settings"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "PPPoE settings file not found. Skipping." >> $LOGFILE
else
   # read pppoe info ($enable_pppoe、$pppoe_account、$pppoe_password)
   . "$SETTINGS_FILE"
fi

# Count the number of physical network interfaces
count=0
ifnames=""
for iface in /sys/class/net/*; do
  iface_name=$(basename "$iface")
  # Check if the interface is a physical device
  if [ -e "$iface/device" ] && echo "$iface_name" | grep -Eq '^eth|^en'; then
    count=$((count + 1))
    ifnames="$ifnames $iface_name"
  fi
done
# remove leading whitespace
ifnames=$(echo "$ifnames" | awk '{$1=$1};1')

# Network configuration
if [ "$count" -eq 1 ]; then
   # single port interface, use DHCP to obtain IP address
   # do not set ip address
   uci set network.lan.proto='dhcp'
elif [ "$count" -gt 1 ]; then
   # get first interface name as WAN
   wan_ifname=$(echo "$ifnames" | awk '{print $1}')
   # get remaining interface names as LAN
   lan_ifnames=$(echo "$ifnames" | cut -d ' ' -f2-)
   # setting WAN interface
   uci set network.wan=interface
   # setting WAN interface name
   uci set network.wan.device="$wan_ifname"
   # setting WAN interface DHCP as default
   uci set network.wan.proto='dhcp'
   # binding WAN6 interface to eth0
   uci set network.wan6=interface
   uci set network.wan6.device="$wan_ifname"
   # Update LAN interfaces
   # find devices section name
   section=$(uci show network | awk -F '[.=]' '/\.@?device\[\d+\]\.name=.br-lan.$/ {print $2; exit}')
   if [ -z "$section" ]; then
      echo "error: cannot find device 'br-lan'." >> $LOGFILE
   else
      # delete original ports list
      uci -q delete "network.$section.ports"
      # add new ports
      for port in $lan_ifnames; do
         uci add_list "network.$section.ports"="$port"
      done
      echo "ports of device 'br-lan' are update." >> $LOGFILE
   fi
   # Set static IP address for the LAN interface
   uci set network.lan.proto='static'
   # for multiple interfaces, possible to set other IP address
   uci set network.lan.ipaddr='192.168.1.1'
   uci set network.lan.netmask='255.255.255.0'
   echo "set 192.168.1.1 at $(date)" >> $LOGFILE
   # check if PPPoE enabled
   echo "print enable_pppoe value=== $enable_pppoe" >> $LOGFILE
   if [ "$enable_pppoe" = "yes" ]; then
      echo "PPPoE is enabled at $(date)" >> $LOGFILE
      # set IPv4 PPPoE configuration
      uci set network.wan.proto='pppoe'
      uci set network.wan.username=$pppoe_account
      uci set network.wan.password=$pppoe_password
      uci set network.wan.peerdns='1'
      uci set network.wan.auto='1'
      # ipv6 not configured by default
      uci set network.wan6.proto='none'
      echo "PPPoE configuration completed successfully." >> $LOGFILE
   else
      echo "PPPoE is not enabled. Skipping configuration." >> $LOGFILE
   fi
fi


# set all interfaces can access web terminal
uci delete ttyd.@ttyd[0].interface

# set all interfaces can acccess SSH
uci set dropbear.@dropbear[0].Interface=''
uci commit

# change packages sources to mirror
sed -e 's,https://downloads.immortalwrt.org,https://mirrors.cernet.edu.cn/immortalwrt,g' \
    -e 's,https://mirrors.vsean.net/openwrt,https://mirrors.cernet.edu.cn/immortalwrt,g' \
    -i.bak /etc/opkg/distfeeds.conf

# copyright info
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Compiled by Jason Ding"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

exit 0
