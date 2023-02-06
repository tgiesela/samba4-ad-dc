# samba4-ad-dc
Samba4 Active directory project for docker with SSH installed.

## First time configuration
Build the docker image:

>docker build -t yourimage.

When starting the image for the first time, some additional parameters are
required to configure the Active Directory domain controller:

```
First time use:
      ./dc_configure.sh

      Answer the questions or use the defaults.

      From then use docker-compose to stop and start the containers
```

You can omit the two password environment variables. The init script will 
generate random passwords and display the passwords in the docker logs.

The volume parameters (-v) can be used to store the configuration of samba and
the ldap database. You can also use a data container to persist the data.

## Environment variables

- SAMBA_REALM:  the actual domain name
- SAMBA_DOMAIN: the short domain name used by samba
- SAMBA_DOMAIN_LC: the domain name in lower-case
- SAMBA_ADMIN_PASSWORD: (optional) the password used to administer the domain controller.
- SAMBA_DNS_FORWARDER: (optional) ip-address of DNS-server used for forwarding
