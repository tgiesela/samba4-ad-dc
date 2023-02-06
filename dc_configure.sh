#!/bin/bash

DEFAULT_DOMAIN="TEST.local"
DEFAULT_DATAFOLDER=/dockerdata
DEFAULT_BACKUPFOLDER=/dockerbackup
INETDEV=$(ip route get 8.8.8.8 | grep -oP 'dev \K[^ ]+')
INETADDR=$(ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+')
DEFAULT_IP_ADDRESS=${INETADDR}

read -p "Password for root/samba/kerberos user: " ROOT_PASSWORD

read -p "Domain (${DEFAULT_DOMAIN}): " SAMBA_DOMAIN
if [ -z $SAMBA_DOMAIN ]; then
     SAMBA_DOMAIN=${DEFAULT_DOMAIN}
fi

#Split domain-name to get the SAMBA_DOMAIN without suffix
IFS="."
arrwords=($SAMBA_DOMAIN)
unset IFS
SAMBA_REALM=${arrwords[0]}

read -p "Fixed ip-address for AD server (${DEFAULT_IP_ADDRESS}): " FIXED_IP_ADDRESS
if [ -z $FIXED_IP_ADDRESS ]; then
    FIXED_IP_ADDRESS=${DEFAULT_IP_ADDRESS}
fi

read -p "Name of folder to store persistent data (${DEFAULT_DATAFOLDER}): " DATAFOLDER
if [ -z $DATAFOLDER ]; then
    DATAFOLDER=${DEFAULT_DATAFOLDER}
fi

read -p "Name of folder to store backups (${DEFAULT_BACKUPFOLDER}): " BACKUPFOLDER
if [ -z $BACKUPFOLDER ]; then
    BACKUPFOLDER=${DEFAULT_BACKUPFOLDER}
fi

SAMBA_DOMAIN_LC=$(echo ${SAMBA_DOMAIN}| awk '{print tolower($0)}')
#docker rm pdc
#rm /dockerdata/samba/.alreadysetup
set > .env
docker-compose build 
docker-compose up -d

