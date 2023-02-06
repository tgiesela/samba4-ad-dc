FROM debian

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/etc/ntp.conf"]
# Setup and install various tools
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y net-tools nano apt-utils wget procps

# Install sambe pre-requisites
RUN apt-get -y install ntp ntpdate

ADD scripts/init.sh /init.sh
RUN chmod 755 /init.sh
RUN apt-get clean
EXPOSE 123 
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
