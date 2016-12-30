# samba4-ad-dc
Samba4 Active directory project for docker with SSH installed.

## First time configuration
Build the docker image:

>docker build -t yourimage.

When starting the image for the first time, some additional parameters are
required to configure the Active Directory domain controller:

```
docker run 
        --privileged 
        -h pdc 
        -v ${PWD}/samba:/var/lib/samba 
        -v ${PWD}/samba:/etc/samba 
        -e SAMBA_REALM="test.local" 
        -e SAMBA_DOMAIN="test" 
        -e ROOT_PASSWORD="<yourpassword>" 
        -e SAMBA_ADMIN_PASSWORD="<yourpassword>" 
        -e SAMBA_DNS_FORWARDER="8.8.8.8" 
        --name dc1 
        --dns-search=test.local 
        --dns=127.0.0.1 
        --net=dvv 
       --ip=<your-fixed-ip-address> 
        -d yourimage
```

You can omit the two password environment variables. The init script will 
generate random passwords and display the passwords in the docker logs.

The volume parameters (-v) can be used to store the configuration of samba and
the ldap database. You can also use a data container to persist the data.

If you want the domain controller to be accessible to the outside world you
can export the ports mentioned in the Dockerfile.
Note: 	I don't use it that way. I connect to the docker host using an openvpn
	connection. This gives the clients access to the domain controller without
	exposing the ports on the docker host.

## Environment variables

- SAMBA_REALM:  the actual domain name
- SAMBA_DOMAIN: the short domain name used by samba
- SAMBA_ADMIN_PASSWORD: (optional) the password used to administer the domain controller.
- ROOT_PASSWORD: (optional) the password for the root user
- SAMBA_DNS_FORWARDER: (optional) ip-address of DNS-server used for forwarding
