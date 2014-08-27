#!/bin/sh

# Configure keystone
crudini --set /etc/keystone/keystone.conf \
	DEFAULT \
	driver \
	keystone.identity.backends.sql.Identity
crudini --set /etc/keystone/keystone.conf \
	DEFAULT \
	idle_timeout \
	200
crudini --set /etc/keystone/keystone.conf \
	DEFAULT \
	admin_token \
	ADMIN
crudini --del /etc/keystone/keystone.conf \
	DEFAULT \
	log_file
crudini --set /etc/keystone/keystone.conf \
	signing \
	certfile \
	/srv/keystone/ssl/certs/signing_cert.pem
crudini --set /etc/keystone/keystone.conf \
	signing \
	keyfile \
	/srv/keystone/ssl/private/signing_key.pem
crudini --set /etc/keystone/keystone.conf \
	signing \
	ca_certs \
	/srv/keystone/ssl/certs/ca.pem
crudini --set /etc/keystone/keystone.conf \
	signing \
	ca_key \
	/srv/keystone/ssl/private/cakey.pem

