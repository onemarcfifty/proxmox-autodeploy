#!/bin/bash

# ########################################################
# ########################################################
# auto-deploy script for the OneMarcFifty network test lab
# ########################################################
# ########################################################


# ########################################################
# include common values
# ########################################################

. common.sh

echo "# ########################################################"
echo "# create OpenWrt VM (Perimeter Router)"
echo "# ########################################################"

qm create $OPENWRTID --cores 1 --name "OpenWrt" --net0 model=virtio,bridge=$OPENWRT_IF --net1 model=virtio,bridge=$EGRESS_IF --storage $DEFAULT_STORAGE --memory 512

# download OpenWrt image and unzip on the fly

wget -O - $OPENWRTURL | gunzip -c >/tmp/openwrt.img

# import into the OpenWrt VM and attach it

qm importdisk $OPENWRTID /tmp/openwrt.img $DEFAULT_STORAGE --format qcow2
qm set $OPENWRTID --ide0 $DEFAULT_STORAGE:vm-$OPENWRTID-disk-0
qm set $OPENWRTID --boot order=ide0

# now remove the temporary image

rm /tmp/openwrt.img

echo "# ########################################################"
echo "# now create the shaper machines"
echo "# ########################################################"

for i in `seq 1 3`;
do
    var="SHAPER${i}_CONFIG"
    CTNAME=$(echo ${!var} | cut -d "," -f1)
    CTBRIDGE=$(echo ${!var} | cut -d "," -f2)
    CTIP=$(echo ${!var} | cut -d "," -f3)
    CTID=$(echo ${!var} | cut -d "," -f4)
    pct create $CTID $CTTEMPLATE --cores 1 --description "Traffic shaper $CTNAME" --hostname $CTNAME --memory 512 --password $DEFAULT_ROOT_PASSWORD --storage $DEFAULT_STORAGE --net0 name=eth0,bridge=$OPENWRT_IF,ip=dhcp --net1 name=eth1,bridge=$CTBRIDGE,ip=$CTIP
done    

echo "# ########################################################"
echo "# create the OpenMPTCPRouter (OMR) Image"
echo "# ########################################################"

BR1=$(echo $SHAPER1_CONFIG | cut -d "," -f2)
BR2=$(echo $SHAPER2_CONFIG | cut -d "," -f2)
BR3=$(echo $SHAPER3_CONFIG | cut -d "," -f2)

qm create $OMR_ID --cores 1 --name "OpenMPTCPRouter" --net0 model=virtio,bridge=$OMR_IF --net1 model=virtio,bridge=$BR1 --net2 model=virtio,bridge=$BR2 --net3 model=virtio,bridge=$BR3 --storage $DEFAULT_STORAGE --memory 512

# download OMR image and unzip on the fly

wget -O - $OMR_URL | gunzip -c >/tmp/omr.img

# import into the OMR VM

qm importdisk $OMR_ID /tmp/omr.img $DEFAULT_STORAGE --format qcow2
qm set $OMR_ID --ide0 $DEFAULT_STORAGE:vm-$OMR_ID-disk-0
qm set $OMR_ID --boot order=ide0

# now remove the temporary image

rm /tmp/omr.img

echo "# ########################################################"
echo "# create the client Container"
echo "# ########################################################"

pct create $CLIENT_CT_ID $CTTEMPLATE --cores 1 --description "OMR client" --hostname $CLIENT_CT_NAME --memory 2048 --password $DEFAULT_ROOT_PASSWORD --storage $DEFAULT_STORAGE --net0 name=eth0,bridge=$OMR_IF,ip=dhcp --net1 name=eth1,bridge=$INGRESS_IF,ip=dhcp
