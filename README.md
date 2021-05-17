# Proxmox Autodeploy

This example shows how to use container creation and modification commands such as pct in order to create a complete network on Proxmox.

The example is based on the MPTCPRouter example network as outlined in [Marc's video on youtube ](https://www.youtube.com/watch?v=S-Xmcig1ddA&t=15s)

## How to use

There are a couple of pre-requisites before you can run the scripts.

### Config file

The config of the environment is outlined in the file common.sh. Here you can find the default root password, the Container IDs and the VM IDs used as well as the names of the bridges please adapt as needed

### Networks

by default, the script needs to have the following networks ready:

* vmbr0 - that is the default ingress and egress network
* vmbr6 - The network between the perimeter router and the shapers
* vmbr7 - one of the shaper inbound networks on 10.7.0.0/24
* vmbr8 - one of the shaper inbound networks on 10.8.0.0/24
* vmbr9 - one of the shaper inbound networks on 10.9.0.0/24
* vmbr10 - the network between OMR and the OMR client

### The container Template

In order to deploy the containers you need an existing Debian 10 template which you can install with pveam

### The scripts

In order to deploy, first run deploy.sh
This will create the VMs and containers

Next, run deploy2.sh
This will start the machine and install software into them

### accessing the environment

The omr-client is a container with a Ubuntu and MATE desktop. You can access it with X2GO. From there you can browse to 192.168.100.1 (your OpenMPTCPRouter)

## TODO

* The shaper nodejs interface is missing
* The VPS for OpenMPTCPRouter is missing

