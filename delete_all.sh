#!/bin/bash

# ########################################################
# ########################################################
# This script deletes the whole environment !! 
# Use with care
# ########################################################
# ########################################################


# ########################################################
# include common values
# ########################################################

. common.sh

for i in `seq 1 3`;
do
    var="SHAPER${i}_CONFIG"
    CTID=$(echo ${!var} | cut -d "," -f4)
    pct destroy $CTID --force --purge
done

pct destroy $CLIENT_CT_ID --force --purge

qm stop $OMR_ID
qm stop $OPENWRTID
qm destroy $OMR_ID --purge
qm destroy $OPENWRTID --purge
