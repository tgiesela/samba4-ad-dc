# samba4-ad-dc
Samba4 Active directory project for docker

## First time configuration
When starting the image for the first time, some additional parameters are
required to configure the Active Directory domain controller:

docker run 
        --privileged 
        -h pdc 
        -v ${PWD}/samba:/var/lib/samba 
        -v ${PWD}/samba:/etc/samba 
        -e SAMBA_REALM="test.local" 
        -e SAMBA_DOMAIN="test" 
        -e ROOT_PASSWORD="<yourpassword>" 
        -e SAMBA_ADMIN_PASSWORD="<yourpassword>" 
        -e KERBEROS_PASSWORD="<yourpassword>" 
        -e SAMBA_DNS_FORWARDER="8.8.8.8" 
        --name dc1 
        --dns-search=test.local 
        --dns=127.0.0.1 
        --net=dvv 
        --ip=172.18.0.3 
        -d tgiesela/samba4:v0.1

You can omit the three password environment variables. The init script will 
generate random passwords and display the passwords in the docker logs.
