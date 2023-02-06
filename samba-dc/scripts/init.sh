#!/bin/bash

#set -e

SAMBA_DOMAIN=${SAMBA_DOMAIN:-samdom}
SAMBA_DOMAIN_LC=$(echo ${SAMBA_DOMAIN}| awk '{print tolower($0)}')
SAMBA_REALM=${SAMBA_REALM:-samdom.example.com}
ROOT_PASSWORD=${ROOT_PASSWORD:-$(pwgen -cny -c -n -1 12)}
SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD:-$(pwgen -cny 10 1)}
KERBEROS_PASSWORD=${KERBEROS_PASSWORD:-$(pwgen -cny 10 1)}
HOSTNAME=$(hostname)

appSetup () {
    export KERBEROS_PASSWORD=${KERBEROS_PASSWORD}
    echo "root:${ROOT_PASSWORD}" | chpasswd
#    echo Root password: ${ROOT_PASSWORD}
#    echo Samba administrator password: ${SAMBA_ADMIN_PASSWORD}
#    echo Kerberos KDC database master key: ${KERBEROS_PASSWORD}
   echo Samba options: ${SAMBA_OPTIONS}

    # Provision Samba
   echo Provisioning SAMBA --domain=${SAMBA_REALM} --realm=${SAMBA_DOMAIN} --host-ip=${SAMBA_HOST_IP} 

   samba-tool domain provision \
	--use-rfc2307 \
	--server-role=dc\
	--dns-backend=SAMBA_INTERNAL \
	--realm=${SAMBA_DOMAIN} \
	--domain=${SAMBA_REALM} \
	--adminpass=${SAMBA_ADMIN_PASSWORD} \
        --host-ip=${SAMBA_HOST_IP} \
	--option="bind interfaces only=yes"

    startSambaBackground
#   copy krb5.conf according to output from provision command (e.g. do not create symlink!)
    rm /etc/krb5.conf
    cp /usr/local/samba/private/krb5.conf /etc/krb5.conf

#   Test zone lookup
    echo " TESTING DNS LOOKUP "
    host -t SRV _ldap._tcp.${SAMBA_DOMAIN_LC}
    host -t SRV _kerberos._udp.${SAMBA_DOMAIN_LC}
    host -t A samba-dc.${SAMBA_DOMAIN_LC}
    echo " DONE TESTING DNS LOOKUP "

#   Create DNS Reverse lookup zone
    echo " CREATING DNS REVERSE ZONE LOOKUP "
    IFS=. read ip1 ip2 ip3 ip4 <<< "${SAMBA_HOST_IP}"
    samba-tool dns zonecreate ${HOSTNAME} ${ip3}.${ip2}.${ip1}.in-addr.arpa -U Administrator --password ${SAMBA_ADMIN_PASSWORD}
    echo " DONE CREATING DNS REVERSE ZONE LOOKUP "

    # Export kerberos keytab for use with sssd
#    echo Export keytab Kerberos 
#    samba-tool domain exportkeytab /etc/krb5.keytab --principal ${HOSTNAME}\$

# Update dns-forwarder if required
    [ -n "$SAMBA_DNS_FORWARDER" ] \
        && sed -i "s/dns forwarder = .*/dns forwarder = $SAMBA_DNS_FORWARDER/" /etc/samba/smb.conf

# Grant Domain Admins the right to set share permission
    net rpc rights grant "Domain Admins" SeDiskOperatorPrivilege -U "${SAMBA_REALM}/Administrator"%${SAMBA_ADMIN_PASSWORD}

    pid=$(cat /usr/local/samba/var/run/samba.pid);kill -9 $pid

    touch /etc/samba/.alreadysetup
}

startSambaBackground() {
    # Start the services
    /usr/local/samba/sbin/samba --daemon
}
startSamba() {
    # Start the services
    /usr/local/samba/sbin/samba -i
}

appStart () {
    export PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH
    [ -f /etc/samba/.alreadysetup ] && echo "Skipping setup..." || appSetup
    startSamba
}

appHelp () {
	echo "Available options:"
	echo " app:start          - Starts all services needed for Samba AD DC"
	echo " app:setup          - First time setup."
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
	app:start)
		appStart
		;;
	app:setup)
		appSetup
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0
