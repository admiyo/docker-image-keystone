FROM larsks/runit
MAINTAINER lars@oddbit.com

RUN yum -y install \
	python-pbr \
	git \
	python-devel \
	python-setuptools \
	python-pip \
	gcc \
	libxml2-python \
	libxslt-python \
	python-lxml \
	sqlite \
	python-repoze-lru  \
	crudini \
	yum-utils

# This pulls in all the dependencies of the python-keystone package
# without actually installing python-keystone (because we're going to install
# that from source).
RUN yum -y install $(repoquery --requires python-keystone | awk '{print $1}')

# Download and install keystone from source.
WORKDIR /opt
RUN git clone http://github.com/openstack/keystone.git
WORKDIR /opt/keystone
RUN python setup.py install

# Install the sample configuration files.
RUN mkdir -p /etc/keystone
RUN cp etc/keystone.conf.sample /etc/keystone/keystone.conf
RUN cp etc/keystone-paste.ini /etc/keystone/
RUN cp etc/policy.json /etc/keystone/

# Configure keystone
RUN crudini --set /etc/keystone/keystone.conf \
	DEFAULT \
	driver \
	keystone.identity.backends.sql.Identity
RUN crudini --set /etc/keystone/keystone.conf \
	DEFAULT \
	idle_timeout \
	200
RUN crudini --set /etc/keystone/keystone.conf \
	DEFAULT \
	admin_token \
	ADMIN
RUN crudini --del /etc/keystone/keystone.conf \
	DEFAULT \
	log_file
RUN crudini --set /etc/keystone/keystone.conf \
	database \
	connection \
	sqlite:////srv/keystone/keystone.db
RUN crudini --set /etc/keystone/keystone.conf \
	signing \
	certfile \
	/srv/keystone/ssl/certs/signing_cert.pem
RUN crudini --set /etc/keystone/keystone.conf \
	signing \
	keyfile \
	/srv/keystone/ssl/private/signing_key.pem
RUN crudini --set /etc/keystone/keystone.conf \
	signing \
	ca_certs \
	/srv/keystone/ssl/certs/ca.pem
RUN crudini --set /etc/keystone/keystone.conf \
	signing \
	ca_key \
	/srv/keystone/ssl/private/cakey.pem

RUN useradd -r -d /srv/keystone -m keystone

VOLUME /srv/keystone
EXPOSE 5000
EXPOSE 35357

