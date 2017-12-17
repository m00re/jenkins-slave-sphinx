FROM centos:7.3.1611
MAINTAINER Jens Mittag <kontakt@jensmittag.de>

# Jenkins Swarm Version
ARG SWARM_VERSION=3.6
ARG SWARM_SHA=e9ee5866393ccae0d4b5500ce5521e2850c98cf7

# Tini Zombie Reaper and Signal Forwarder Version
ARG TINI_VERSION=0.13.2
ARG TINI_SHA=afbf8de8a63ce8e4f18cb3f34dfdbbd354af68a1

# Container Internal Environment Variables
ENV SWARM_HOME=/opt/jenkins-swarm \
    SWARM_WORKDIR=/opt/jenkins \
    GOSU_VERSION=1.10

# Install Development Tools
RUN yum install -y epel-release
RUN yum install -y \
      unzip \
      tar \
      gzip \
      wget \
      dpkg \
      nano \
      git \
      doxygen \
      make \
      java-1.8.0-openjdk-headless

# Install gosu...
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    	wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    	wget -O /tmp/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    	\
    # ... and verify the signature
    	export GNUPGHOME="$(mktemp -d)"; \
    	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    	gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu; \
    	rm -r "$GNUPGHOME" /tmp/gosu.asc; \
    	\
    	chmod +x /usr/bin/gosu; \
    # ... as well verify that the binary works
    	gosu nobody true;

# Install Tini Zombie Reaper And Signal Forwarder
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha1sum -c -

# Install Jenkins Swarm-Slave
RUN mkdir -p ${SWARM_HOME} && \
    wget --directory-prefix=${SWARM_HOME} \
      https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar && \
    sha1sum ${SWARM_HOME}/swarm-client-${SWARM_VERSION}.jar && \
    echo "$SWARM_SHA ${SWARM_HOME}/swarm-client-${SWARM_VERSION}.jar" | sha1sum -c - && \
    mv ${SWARM_HOME}/swarm-client-${SWARM_VERSION}.jar ${SWARM_HOME}/swarm-client.jar && \
    mkdir -p ${SWARM_WORKDIR}

# Install Sphinx
RUN yum install -y python2-pip && \
    pip install --upgrade pip && \
    pip install sphinx && \
    pip install breathe

# Cleanup yum
RUN yum clean all && rm -rf /var/cache/yum/*

# Entrypoint Environment Variables
ENV SWARM_VM_PARAMETERS= \
    SWARM_MASTER_URL= \
    SWARM_VM_PARAMETERS= \
    SWARM_JENKINS_USER= \
    SWARM_JENKINS_PASSWORD= \
    SWARM_CLIENT_EXECUTORS= \
    SWARM_CLIENT_LABELS= \
    SWARM_CLIENT_NAME= \
    RUN_WITH_USER_ID=1000 \
    RUN_WITH_GROUP_ID=1000 \
    IMPORT_HOME_FROM= \
    SWARM_HOME=${SWARM_HOME} \
    SWARM_WORKDIR=${SWARM_WORKDIR}

COPY docker-entrypoint.sh ${SWARM_HOME}/docker-entrypoint.sh
COPY run-jenkins.sh ${SWARM_HOME}/run-jenkins.sh

WORKDIR $SWARM_WORKDIR
ENTRYPOINT ["/bin/tini","--","/opt/jenkins-swarm/docker-entrypoint.sh"]
CMD ["swarm"]
