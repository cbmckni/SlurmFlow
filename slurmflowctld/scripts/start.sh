#!/bin/bash

HOST="scidas-scratch1.clemson.edu"
PORT="1247"
UNAME="cbmckni"
ZONE="scidasZone"


if [ -z ${SLURM_CLUSTER_NAME+x} ]; then echo "SLURM_CLUSTER_NAME not set" && exit 1; fi
if [ -z ${SLURM_CONTROL_MACHINE+x} ]; then echo "SLURM_CONTROL_MACHINE not set" && exit 1; fi
if [ -z ${SLURM_NODE_NAMES+x} ]; then echo "SLURM_NODE_NAMES not set" && exit 1; fi
if [ -z ${INFLUXDB_HOST+x} ]; then echo "INFLUXDB_HOST not set" && exit 1; fi
if [ -z ${INFLUXDB_DATABASE_NAME+x} ]; then echo "INFLUXDB_DATABASE_NAME not set" && exit 1; fi

sed -i -e "s/###SLURM_CLUSTER_NAME###/${SLURM_CLUSTER_NAME}/g" /usr/local/etc/slurm.conf
sed -i -e "s/###SLURM_CONTROL_MACHINE###/${SLURM_CONTROL_MACHINE}/g" /usr/local/etc/slurm.conf
sed -i -e "s/###SLURM_NODE_NAMES###/${SLURM_NODE_NAMES}/g" /usr/local/etc/slurm.conf
sed -i -e "s/###INFLUXDB_HOST###/${INFLUXDB_HOST}/g" /usr/local/etc/acct_gather.conf
sed -i -e "s/###INFLUXDB_DATABASE_NAME###/${INFLUXDB_DATABASE_NAME}/g" /usr/local/etc/acct_gather.conf

#init nextflow 
nextflow

# Create the iRODs user settings file.
mkdir ~/.irods
echo "Setting up iRODs..."
echo '{' > ~/.irods/irods_environment.json
echo "  \"irods_host\": \"$HOST\"," >> ~/.irods/irods_environment.json
echo "  \"irods_port\": \"$PORT\"," >> ~/.irods/irods_environment.json
echo "  \"irods_user_name\": \"$UNAME\"," >> ~/.irods/irods_environment.json
echo "  \"irods_zone_name\": \"$ZONE\"" >> ~/.irods/irods_environment.json
echo "}" >> ~/.irods/irods_environment.json
iinit

ils

/usr/bin/supervisord --nodaemon
