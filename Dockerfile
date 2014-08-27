FROM larsks/runit:fedora20
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

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

ADD configure-keystone.sh /opt/keystone/configure-keystone.sh
RUN sh /opt/keystone/configure-keystone.sh

RUN useradd -r -d /srv/keystone -m keystone
RUN mkdir -p /etc/runit/sysinit
ADD keystone.sysinit /etc/runit/sysinit/keystone
ADD service/ /service/

VOLUME /srv/keystone
EXPOSE 5000
EXPOSE 35357

