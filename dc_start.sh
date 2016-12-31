#!/bin/bash

DEFAULT_DOMAIN="test.local"
DEFAULT_DATAFOLDER=/dockerdata

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

read -p "Fixed ip-address for AD server: " FIXED_IP_ADDRESS
if [ ! -z $FIXED_IP_ADDRESS ]; then
    IP_COMMAND=--ip=${FIXED_IP_ADDRESS}
fi

read -p "Name of folder to store persistent data (${DEFAULT_DATAFOLDER}): " DATAFOLDER
if [ -z $DATAFOLDER ]; then
    DATAFOLDER=${DEFAULT_DATAFOLDER}
fi

read -p "Do you want to use custom network? (y/n) " yn
case $yn in
    [Yy]* )
            read -p "Custom network name : " CUSTOMNETWORKNAME
	    if [ ! -z $CUSTOMNETWORKNAME ]; then CUSTOMNETWORKNAME=--net=${CUSTOMNETWORKNAME}; fi
	    ;;
        * ) CUSTOMNETWORKNAME=
            ;;
esac
echo NETWORK: ${CUSTOMNETWORKNAME}
#docker rm pdc
#rm /dockerdata/samba/.alreadysetup
docker run \
	--privileged \
	-h pdc \
	-v ${DATAFOLDER}/samba:/var/lib/samba \
	-v ${DATAFOLDER}/samba:/etc/samba \
	-v ${DATAFOLDER}/sambashares:/shares \
	-e SAMBA_REALM="${SAMBA_DOMAIN}" \
	-e SAMBA_DOMAIN="${SAMBA_REALM}" \
	-e ROOT_PASSWORD="${ROOT_PASSWORD}" \
	-e SAMBA_ADMIN_PASSWORD="${ROOT_PASSWORD}" \
	-e KERBEROS_PASSWORD="${ROOT_PASSWORD}" \
	-e SAMBA_DNS_FORWARDER="8.8.8.8" \
	-e SAMBA_HOST_IP="${FIXED_IP_ADDRESS}" \
	--name pdc \
	--dns=127.0.0.1 \
	--dns-search=$(echo ${SAMBA_DOMAIN}| awk '{print tolower($0)}') \
        ${CUSTOMNETWORKNAME} \
	${IP_COMMAND} \
	-d tgiesela/samba4:v0.1

#	--add-host localhost:127.0.0.1 \
