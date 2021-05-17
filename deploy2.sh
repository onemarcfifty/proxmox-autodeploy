#!/bin/bash

# ########################################################
# ########################################################
# auto-deploy script for the OneMarcFifty network test lab
# part 2 - start the machines and install software 
# and configuration files
# ########################################################
# ########################################################


# ########################################################
# include common values
# ########################################################

. common.sh

echo "# ########################################################"
echo "# Starting OpenWrt VM (Perimeter Router)"
echo "# ########################################################"

qm start $OPENWRTID
sleep 20

# ########################################################
# Starting and configuring the shaper machines
# ########################################################

for i in `seq 1 3`;
do
    var="SHAPER${i}_CONFIG"
    CTNAME=$(echo ${!var} | cut -d "," -f1)
    CTBRIDGE=$(echo ${!var} | cut -d "," -f2)
    CTIP=$(echo ${!var} | cut -d "," -f3)
    CTID=$(echo ${!var} | cut -d "," -f4)

    # here we "guess" the network - but this only works with /24 CIDR
    # i.e. with Class-C Netmask 255.255.255.0
   
    CTNET="${CTIP%.*}.0"
    CTNETCHUNK="${CTIP%.*}"
    CTNETMASK="255.255.255.0"

    echo "# ########################################################"
    echo "# Starting the shaper machine $i ($CTNAME)"
    echo "# ########################################################"

    pct start $CTID
    sleep 10

    echo "# ########################################################"
    echo "# Configuring the shaper machine $i"
    echo "# ########################################################"

    # in this loop we wait until we can contact google.com

    echo "waiting for $CTNAME to get internet connection"
    TESTRESULT="Offline"
    until (echo $TESTRESULT | grep "Online")
    do
        TESTRESULT=$(pct exec $CTID -- wget -q --spider http://google.com ; if [ $? -eq 0 ]; then echo "Online"; else echo "Offline"; fi)
        sleep 1
    done    

    # now copy the config files over to the container

    echo "### copying the rc.local config file"
    pct push $CTID config/rc.local /etc/rc.local --group 0 --perms 755 --user 0

    echo "### Installing software inside the container"

    # update the package list in the container
    # and install the necessary software packages

    pct exec $CTID -- apt update 
    pct exec $CTID -- apt install -y bmon isc-dhcp-server speedometer 
    
    # we have to adapt the DHCP Server config to the network config of the container

    echo "### Configuring DHCP Server inside the container"
    pct exec $CTID -- sed -i s/INTERFACESv4=\"\"/INTERFACESv4=\"eth1\"/g /etc/default/isc-dhcp-server
    pct push $CTID config/dhcpd.conf /etc/dhcp/dhcpd.conf --group 0 --perms 644 --user 0 
    TEMPLATEREPLACECMD="-- sed -i.bak -e s/CTNET/$CTNET/ -e s/CTMASK/$CTNETMASK/ -e s/ROUTERIP/${CTIP%/*}/ -e s/DHCPSTART/$CTNETCHUNK.100/ -e s/DHCPEND/$CTNETCHUNK.120/ /etc/dhcp/dhcpd.conf"
    #echo $TEMPLATEREPLACECMD  
    pct exec $CTID $TEMPLATEREPLACECMD 

    echo "### rebooting the container"
    
    pct reboot $CTID
    sleep 10
    pct exec $CTID -- systemctl status isc-dhcp-server.service
done

echo "# ########################################################"
echo "# starting the OpenMPTCPRouter (OMR) Image"
echo "# ########################################################"


qm start $OMR_ID
sleep 30

echo "# ########################################################"
echo "# starting the client Container"
echo "# ########################################################"

pct start $CLIENT_CT_ID 
sleep 10

# we need to set the OMR WAN interfaces to dhcp
# in order to do this we ssh into OMR from the client machine

#OMR_DHCP_CONFIG_CMD="-- ssh -o StrictHostKeyChecking=no root@$OMR_IP \"uci set network.wan1.ipaddr=dhcp; uci set network.wan2.ipaddr=dhcp; uci set network.wan3.ipaddr=dhcp; uci commit; /etc/init.d/network restart\" "
#pct exec $CLIENT_CT_ID $OMR_DHCP_CONFIG_CMD 
pct exec $CLIENT_CT_ID -- ssh -o StrictHostKeyChecking=no root@$OMR_IP "uci set network.wan1.proto=dhcp; uci set network.wan2.proto=dhcp; uci set network.wan3.proto=dhcp; uci commit; /etc/init.d/network restart"   

# in this loop we wait until we can contact google.com

echo "waiting for the client container to get internet connection"
TESTRESULT="Offline"
until (echo $TESTRESULT | grep "Online") 
do
    TESTRESULT=$(pct exec $CLIENT_CT_ID -- wget -q --spider http://google.com ; if [ $? -eq 0 ]; then echo "Online"; else echo "Offline"; fi)
    sleep 1
done    

# now install the software for the client

pct exec $CLIENT_CT_ID -- apt update 
pct exec $CLIENT_CT_ID -- apt install -y git mate x2goserver firefox-esr

# create a non-root user

pct exec $CLIENT_CT_ID -- useradd -m  $CLIENT_USER
pct exec $CLIENT_CT_ID -- usermod -a -G sudo $CLIENT_USER
XCMD="echo -n $CLIENT_USER:$CLIENT_PASSWORD | chpasswd" ; pct exec $CLIENT_CT_ID -- bash -c "$XCMD"
