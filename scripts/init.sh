#!/bin/bash

set -e

SAMBA_DOMAIN=${SAMBA_DOMAIN:-samdom}
SAMBA_REALM=${SAMBA_REALM:-samdom.example.com}
ROOT_PASSWORD=${ROOT_PASSWORD:-$(pwgen -cny -c -n -1 12)}
SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD:-$(pwgen -cny 10 1)}
KERBEROS_PASSWORD=${KERBEROS_PASSWORD:-$(pwgen -cny 10 1)}


[ -n "$SAMBA_DOMAIN" ] \
    && SAMBA_OPTIONS="$SAMBA_OPTIONS --domain=$SAMBA_DOMAIN" \
    || SAMBA_OPTIONS="$SAMBA_OPTIONS --domain=${SAMBA_REALM%%.*}"

[ -n "$SAMBA_HOST_IP" ] && SAMBA_OPTIONS="$SAMBA_OPTIONS --host-ip=$SAMBA_HOST_IP"

if [[ $SAMBA_HOST_IP ]]; then
    SAMBA_HOST_IP="--host-ip=${SAMBA_HOST_IP}"
fi

appSetup () {
    touch /etc/samba/.alreadysetup

    export KERBEROS_PASSWORD=${KERBEROS_PASSWORD}
    echo "root:${ROOT_PASSWORD}" | chpasswd
    echo Root password: ${ROOT_PASSWORD}
    echo Samba administrator password: ${SAMBA_ADMIN_PASSWORD}
    echo Kerberos KDC database master key: ${KERBEROS_PASSWORD}
    echo Samba options: ${SAMBA_OPTIONS}

    # Provision Samba
    rm -f /etc/samba/smb.conf
    rm -rf /var/lib/samba/private/*
    samba-tool domain provision \
	--use-rfc2307 \
	--domain=${SAMBA_DOMAIN} \
	--realm=${SAMBA_REALM} \
	--server-role=dc\
	--dns-backend=SAMBA_INTERNAL \
	--adminpass=${SAMBA_ADMIN_PASSWORD} \
	${SAMBA_HOST_IP} \
	${SAMBA_OPTIONS} \
	--option="bind interfaces only"=yes

    #rm /etc/krb5.conf 
    #ln -sf /usr/local/samba/private/krb5.conf /etc/krb5.conf

    # cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
    # Create Kerberos database
#    expect kdb5_util_create.expect
    # Export kerberos keytab for use with sssd
    samba-tool domain exportkeytab /etc/krb5.keytab --principal ${HOSTNAME}\$
    #sed -i "s/SAMBA_REALM/${SAMBA_REALM}/" /etc/sssd/sssd.conf

# Update dns-forwarder if required
[ -n "$SAMBA_DNS_FORWARDER" ] \
    && sed -i "s/dns forwarder = .*/dns forwarder = $SAMBA_DNS_FORWARDER/" /etc/samba/smb.conf

# Grant Domain Admins the right to set share permission
    net rpc rights grant "VERZUIM\Domain Admins" SeDiskOperatorPrivilege -U "VERZUIM\Administrator"%${SAMBA_ADMIN_PASSWORD}

}

appStart () {
    [ -f /etc/samba/.alreadysetup ] && echo "Skipping setup..." || appSetup

    # Start the services
    /usr/bin/supervisord
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
