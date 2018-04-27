FROM ubuntu:latest

ENV VERSION 7.9.0-alpha4
ENV GROUP wildfly
ENV DISTRO wildfly10
ENV SERVER wildfly-10.1.0.Final
ENV LIB_DIR /camunda/modules
ENV SERVER_CONFIG /camunda/standalone/configuration/standalone.xml
ENV PREPEND_JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0
ENV NEXUS https://app.camunda.com/nexus/service/local/artifact/maven/redirect
ENV LAUNCH_JBOSS_IN_BACKGROUND TRUE

WORKDIR /camunda

# install oracle java and generate locale
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/oracle-jdk.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && \
    apt-get -y install --no-install-recommends oracle-java8-installer xmlstarlet ca-certificates locales && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/*

# set language to englisch
ENV LANG en_US.UTF-8

# add camunda distro
RUN wget -O - "${NEXUS}?r=public&g=org.camunda.bpm.${GROUP}&a=camunda-bpm-${DISTRO}&v=${VERSION}&p=tar.gz" | \
    tar xzf - -C /camunda/ server/${SERVER} --strip 2

# add wildfly modules
COPY modules /camunda/modules/

# add scripts
ADD bin/* /usr/local/bin/

# add database drivers
RUN /usr/local/bin/download-database-drivers.sh "${NEXUS}?r=public&g=org.camunda.bpm&a=camunda-database-settings&v=${VERSION}&p=pom"

EXPOSE 8080

CMD ["/usr/local/bin/configure-and-run.sh"]
