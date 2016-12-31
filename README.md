# samba4-ad-dc
Samba4 Active directory project for docker with SSH installed.

## First time configuration
Build the docker image:

>docker build .

When starting the image for the first time, some additional parameters are
required to configure the Active Directory domain controller:

```
>docker run 
>        --privileged 
>        -h pdc 
>        -v ${PWD}/samba:/var/lib/samba 
>        -v ${PWD}/samba:/etc/samba 
>        -e SAMBA_REALM="test.local" 
>        -e SAMBA_DOMAIN="test" 
>        -e ROOT_PASSWORD="<yourpassword>" 
>        -e SAMBA_ADMIN_PASSWORD="<yourpassword>" 
>        -e SAMBA_DNS_FORWARDER="8.8.8.8" 
>        --name dc1 
>        --dns-search=test.local 
>        --dns=127.0.0.1 
>        --net=dvv 
>       --ip=<your-fixed-ip-address> 
>        -d tgiesela/samba4:v0.1
```

You can omit the three password environment variables. The init script will 
generate random passwords and display the passwords in the docker logs.

The volume parameters (-v) can be used to store the configuration of samba and
the ldap database. You can also use a data container to persist the data.

## Environement variables

- > SAMBA_REALM:  the actual domain name
- > SAMBA_DOMAIN: the short domain name used by samba
- > SAMBA_ADMIN_PASSWORD: (optional) the password used to administer the domain controller.
- > ROOT_PASSWORD: (optional) the password for the root user
- > SAMBA_DNS_FORWARDER: (optional) ip-address of DNS-server used for forwarding
