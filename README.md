# AutoBuildImmortalWrt

## 🤔 What is this?
It is a workflow for quickly building immortalWrt with docker support and customizable rootfs size

> 1. Supports customizable rootfs size (default 1GB)
> 2. Pre-installed docker (optional) 
> 3. Supports QEMU-ARMv8 and rockchip platforms

## How to check available plugins?

https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/23.05.4/packages/aarch64_cortex-a53/luci/ 

https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/23.05.4/packages/x86_64/luci/ 

## Important Notes for Secondary Router Users

Recently many users mistakenly modify the default IP address in configuration files, thinking this workflow can directly set a secondary router IP. This is a big misunderstanding and will cause issues.

The correct logic for a secondary router should be single-port mode. As shown in the firmware properties below, single-port mode defaults to `DHCP mode`. Users should check the IP assigned to the immortalWrt router from their main router.

Then access the immortalWrt admin page using that IP, and configure the secondary router IP according to the main router's subnet.

## Important Notes for Normal Router Mode

Normal router mode refers to multi-port users (2 or more ports).

Typically WAN port is used for PPPoE dial-up or automatic IP acquisition while other LAN ports provide DHCP to other devices. In this case you can modify the router's default IP `192.168.1.1` to something like `192.168.80.1` etc.

This modification is mainly to avoid conflicts with optical modems or other routers in the home network. Most users don't need to change it.

## Default Firmware Properties (Must Read)

- When flashed to 【single-port devices】, it defaults to DHCP mode, automatically obtaining IP (similar to NAS)
- When flashed to 【multi-port devices】, WAN port defaults to DHCP mode, LAN port IP is `192.168.1.1` <br>eth0 is WAN, other ports are LAN
- If PPPoE info is configured in workflow, WAN port will use PPPoE dial-up mode
- Recommended to restart optical modem once before using PPPoE
- For 【single-port devices】, connect to router first and check its IP from main router before accessing
- All above settings can be configured and adjusted via `99-custom.sh`

# 🌟 Credits
### https://github.com/immortalwrt
