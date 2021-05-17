# DEFAULT_ROOT_PASSWORD is the root password to use for the containers

DEFAULT_ROOT_PASSWORD=topSecret

# DEFAULT_STORAGE tells us where to put the images

DEFAULT_STORAGE=local-lvm

# CTTEMPLATE contains the name of the container template to use. 
# This can be something like local:vztmpl/debian-10-standard_10.5-1_amd64.tar.gz
# what we do here is we list all templates on the local storage 
# and then search for the term "debian-10"
# please adapt as you need

CTTEMPLATE=$(pveam list local |grep "debian-10" | cut -d " " -f 1 -)

# OPENWRTURL contains the URL for the OpenWrt Image to use.

OPENWRTURL="https://downloads.openwrt.org/releases/19.07.7/targets/x86/generic/openwrt-19.07.7-x86-generic-combined-ext4.img.gz"

# OPENWRTID is the VM ID for the OpenWrt image

OPENWRTID=700

# EGRESS_IF is the name of the bridge that points to the outside world, i.e. to the internet
# so in fact the OpenWrt's WAN interface

EGRESS_IF=vmbr0

# INGRESS_IF is the name of the bridge that we use to access the outmost right node via x2go

INGRESS_IF=vmbr0

# OPENWRT_IF is the bridge between the Perimeter OpenWrt router and the shapers
# so in fact the OpenWrt's LAN interface

OPENWRT_IF=vmbr6
OPENWRT_IP=192.168.1.1

# SHAPERn_CONFIG contains the configuration variables for the 1st shaper
# The first variable is the name of the machine
# the second value is the name of the bridge
# the third value is the ip address
# the fourth value is the ID of the Container


SHAPER1_CONFIG=shaper1,vmbr7,10.7.0.1/24,701
SHAPER2_CONFIG=shaper2,vmbr8,10.8.0.1/24,702
SHAPER3_CONFIG=shaper3,vmbr9,10.9.0.1/24,703

# the OpenMPTCPRouter Image
# OMR_URL contains the URL for the OpenMPTCPRouter Image to use.

OMR_URL="https://download.openmptcprouter.com/release/v0.57.3/x86_64/targets/x86/64/openmptcprouter-v0.57.3-r0+15225-bfc433efd4-x86-64-generic-ext4-combined.img.gz"

# OMR_ID is the VM ID for the OMR image

OMR_ID=704

# OMR_IF is the bridge between the OMR and the OMR client
# so in fact OMR's LAN interface
# please make sure that your Proxmox Bridge configuration is correct, e.g. 192.168.100.2/24

OMR_IF=vmbr10
OMR_IP=192.168.100.1

# the Client Container config

CLIENT_CT_ID=705
CLIENT_CT_NAME=omr-client
CLIENT_USER=OneMarcFifty
CLIENT_PASSWORD=LikeAndSubscribe

# Settings for the Debian VMs (VPS and MPTCP Client)
# you can either create those manually 
# or from a template
# or from a downloaded installation disk
# or from an iso in your repo

VPS_ID=706

# this is an example of an installation medium to download

DEBIANURL="https://deb.debian.org/debian/dists/buster/main/installer-amd64/current/images/hd-media/boot.img.gz"

# and here is an example on how to find an existing iso
# if your iso files are on the "local" storage

DEBIANISO=$(pvesm list local -content iso |grep "debian-10" | cut -d " " -f 1 -)
