FROM debian

ENV DEBIAN_FRONTEND noninteractive

# Setup and install tools
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y net-tools nano apt-utils wget procps

# Install sambe pre-requisites
RUN apt-get -y install \
    acl apt-utils attr autoconf bind9utils binutils \
    bison build-essential ccache chrpath curl \
    debhelper dnsutils docbook-xml docbook-xsl \
    flex gcc gdb git glusterfs-common gzip \
    heimdal-multidev hostname htop jq \
    krb5-config krb5-kdc krb5-user lcov \
    libacl1-dev libarchive-dev libattr1-dev \
    libavahi-common-dev libblkid-dev libbsd-dev \
    libcap-dev libcephfs-dev libcups2-dev \
    libdbus-1-dev libglib2.0-dev libgnutls28-dev \
    libgpgme11-dev libicu-dev libjansson-dev \
    libjs-jquery libjson-perl libkrb5-dev \
    libldap2-dev liblmdb-dev libncurses5-dev \
    libpam0g-dev libparse-yapp-perl libpcap-dev \
    libpopt-dev libreadline-dev libsystemd-dev \
    libtasn1-bin libtasn1-dev libtracker-sparql-2.0-dev \
    libunwind-dev liburing-dev lmdb-utils \
    locales lsb-release make mawk \
    mingw-w64 patch perl perl-modules \
    pkg-config procps psmisc python3 \
    python3-cryptography python3-dbg \
    python3-dev python3-dnspython python3-gpg \
    python3-iso8601 python3-markdown python3-pexpect \
    python3-pyasn1 python3-requests python3-setproctitle \
    rng-tools rsync sed sudo \
    tar tree uuid-dev wget xfslibs-dev \
    xsltproc xz-utils zlib1g-dev

RUN mkdir -p /home/samba && cd /home/samba
WORKDIR /home/samba
RUN wget --no-check-certificate https://download.samba.org/pub/samba/stable/samba-4.17.5.tar.gz
RUN tar -zxf samba-4.17.5.tar.gz
WORKDIR /home/samba/samba-4.17.5/
RUN ./configure --sysconfdir=/etc/samba \
                --prefix=/ \
                --with-privatedir=/usr/local/samba/private \
                --with-bind-dns-dir=/usr/local/samba 
                
RUN make && make install

# Install utilities needed for setup
RUN apt-get install -y expect pwgen

# Set kerberos parameters
RUN rm /etc/krb5.conf && \
    ln -sf /etc/samba/private/krb5.conf /etc/krb5.conf

ADD scripts/init.sh /init.sh
ADD scripts/samba_backup.sh /usr/sbin/samba_backup.sh
RUN chmod 755 /init.sh
RUN rm -r /home/samba/
RUN apt-get clean
EXPOSE 53 135 137 138 139 445 464 3268 3269 49152-49160
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
