FROM ubuntu:16.04
MAINTAINER Tonny Gieselaar <tonny@devosverzuimbeheer.nl>

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/var/lib/samba", "/etc/samba"]

# Setup ssh and install supervisord
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server supervisor net-tools nano apt-utils wget

# Install sambe pre-requisites
RUN apt-get install -y acl attr autoconf bison build-essential \
	    debhelper dnsutils docbook-xml docbook-xsl flex gdb krb5-user \
	    libacl1-dev libaio-dev libattr1-dev libblkid-dev libbsd-dev \
	    libcap-dev libcups2-dev libgnutls-dev libjson-perl \
	    libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl \
	    libpopt-dev libreadline-dev perl perl-modules pkg-config \
	    python-all-dev python-dev python-dnspython python-crypto \
	    xsltproc zlib1g-dev

RUN mkdir -p /home/samba && cd /home/samba
WORKDIR /home/samba
RUN wget https://download.samba.org/pub/samba/stable/samba-4.5.3.tar.gz
RUN tar -zxf samba-4.5.3.tar.gz
WORKDIR /home/samba/samba-4.5.3/
RUN ./configure --sysconfdir=/etc/samba/ \ 
--mandir=/usr/share/man/ --sbindir=/usr/sbin/ --bindir=/usr/bin/ \
--with-logfilebase=/var/log/samba --with-lockdir=/var/run/samba \
--with-statedir=/var/lib/samba --with-cachedir=/var/cache/samba \
--with-smbpasswd-file=/etc/samba/smbpasswd \
--with-privatedir=/var/lib/samba/private
                
RUN make && make install

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN sed -ri 's/PermitRootLogin prohibit-password/PermitRootLogin Yes/g' /etc/ssh/sshd_config

# Install utilities needed for setup
RUN apt-get install -y expect pwgen
#ADD kdb5_util_create.expect kdb5_util_create.expect

# Set kerberos parameters
RUN rm /etc/krb5.conf && \
    ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf

ADD scripts/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD scripts/init.sh /init.sh
RUN chmod 755 /init.sh
RUN apt-get clean
EXPOSE 22 53 389 88 135 139 138 445 464 3268 3269
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
