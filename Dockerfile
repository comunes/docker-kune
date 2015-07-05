FROM debian:jessie
MAINTAINER Vicente J. Ruiz Jurado <vjrj@ourproject.org>

ENV DEBIAN_FRONTEND noninteractive
ENV SHELL /bin/bash

ENV DB_ROOT_PWD db4kune
ENV ROOT_PWD changeme

# In development, uncomment to use squid-deb-proxy and a specific mirror
# More info: http://nknu.net/running-docker-behind-a-proxy-on-ubuntu-14-04/
ENV http_proxy http://192.168.1.100:8000
ENV https_proxy http://192.168.1.100:8000
RUN perl -p -i -e 's/httpredir/ftp.fi/g' /etc/apt/sources.list

# Install initial dependencies
RUN apt-get -y update
RUN apt-get install -y -q wget

# Add the kune repo and gpg key
RUN echo deb http://kune.ourproject.org/pub/kune/debian/ unstable/ > /etc/apt/sources.list.d/kune.list
RUN https_proxy="" http_proxy="" gpg --keyserver pgp.mit.edu --recv-keys 9E358A05
RUN gpg --armor --export 9E358A05 | apt-key add -

# Start openfire dependency
# Forked from: https://github.com/sameersbn/docker-openfire/blob/master/Dockerfile
ENV OPENFIRE_VERSION 3.10.2
RUN apt-get -y update \
 && apt-get install -y -q openjdk-7-jre \
 && wget "http://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_${OPENFIRE_VERSION}_all.deb" \
      -O /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
 && dpkg -i /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
 && rm -rf openfire_${OPENFIRE_VERSION}_all.deb #20150702-1

EXPOSE 3478
EXPOSE 3479
EXPOSE 5222
EXPOSE 5223
EXPOSE 5229
EXPOSE 7070
EXPOSE 7443
EXPOSE 7777
EXPOSE 9090
EXPOSE 9091

# End openfire dependency

# https://docs.docker.com/articles/using_supervisord/
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor

# Pre mysql install
# inspired in: https://registry.hub.docker.com/u/ahmet2mir/mysql/dockerfile/
RUN echo "mysql-server mysql-server/root_password password $DB_ROOT_PWD" | debconf-set-selections;\
    echo "mysql-server mysql-server/root_password_again password $DB_ROOT_PWD" | debconf-set-selections;

# Install kune dependencies
RUN apt-get install -y -q mysql-client postfix telnet libjmagick6-jni mysql-server adduser dbconfig-common

# Remove mysql start warning
RUN perl -p -i -e 's/key_buffer/key_buffer_size/g' /etc/mysql/my.cnf

RUN /usr/sbin/mysqld & \
    sleep 5s &&\
    echo "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$DB_ROOT_PWD'; FLUSH PRIVILEGES" | mysql --user=root --password=$DB_ROOT_PWD
# FIXME: Is necessary to expose this port?
EXPOSE 3306

# ssh configuration
# https://docs.docker.com/examples/running_ssh_service/
RUN echo "root:$ROOT_PWD" | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

# We update again if we are testing only the last part with new kune packages
RUN apt-get -y update # 20150705

# kune selections
RUN echo "kune kune/mysql/admin-pass password $DB_ROOT_PWD" | debconf-set-selections;
RUN echo "kune kune/dbconfig-install boolean true" | debconf-set-selections;
RUN echo "kune kune/dbconfig-upgrade boolean true" | debconf-set-selections;

# Kune needs mysql running to install correctly
RUN mkdir -p /var/log/kune
RUN /usr/sbin/mysqld & \
    sleep 5s &&\
    apt-get install -y kune
EXPOSE 8888
# FIXME: Is necessary to expose this port? (http-proxy for chat)
EXPOSE 5280
RUN sed -i -e"s/localhost:8888/0.0.0.0:8888/" /etc/kune/wave-server.properties

# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]
VOLUME  ["/etc/openfire", "/var/lib/openfire", "/usr/share/openfire/logs"]
VOLUME  ["/etc/kune", "/var/lib/kune", "/usr/share/kune/custom", "/var/logs/kune" ]

# This starts: ssh, mysql, openfire and kune (right now)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

# Optional packages
RUN apt-get install -y -q vim less

RUN apt-get clean
