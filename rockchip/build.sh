#!/bin/bash
# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
# show PROFILE defined in yml
echo "Building for profile: $PROFILE"
# show ROOTFS_PARTSIZE in yml
echo "Building for ROOTFS_PARTSIZE: $ROOTFS_PARTSIZE"

# uncomment the following section if you want to set PPPoE settings
: <<'END_COMMENT'
echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# create pppoe-settings file with environment variables set in yml file for 99-custom.sh to read
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings
END_COMMENT

# show debug info
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."


# define the list of packages to be installed, add or remove packages as needed
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
# Service——FileBrowser Username: admin Password: admin
PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
#PACKAGES="$PACKAGES luci-app-openclash"
#PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-vnstat2-zh-cn"
#PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
# some required components if you want to install iStore
#PACKAGES="$PACKAGES fdisk"
#PACKAGES="$PACKAGES script-utils"
#PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"

# build the image
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
