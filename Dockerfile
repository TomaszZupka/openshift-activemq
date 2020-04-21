FROM openjdk:8-jre

ENV ARTIFACTORY=http://artifactory.ci.warta.pl/artifactory \
	ACTIVEMQ_VERSION=5.15.2 \
    POSTGRES_JDBC_DRIVER_VERSION=9.4.1212 \
    ACTIVEMQ_TCP=61616 \
    ACTIVEMQ_HOME=/opt/activemq

ENV ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION

COPY files/docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x && \
    curl -s -S $ARTIFACTORY/newezr-mvn-local/$ACTIVEMQ-bin.tar.gz | tar xvz -C /opt && \
    ln -s /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    cd $ACTIVEMQ_HOME/lib/optional && \
    curl -O $ARTIFACTORY/jcenter-cache/org/postgresql/postgresql/$POSTGRES_JDBC_DRIVER_VERSION/postgresql-$POSTGRES_JDBC_DRIVER_VERSION.jar && \    
    useradd -r -M -d $ACTIVEMQ_HOME activemq && \
    chown -R :0 /opt/$ACTIVEMQ && \
    chown -h :0 $ACTIVEMQ_HOME && \
    chmod go+rwX -R $ACTIVEMQ_HOME && \
    chmod +x /docker-entrypoint.sh

RUN ls

COPY files/activemq.xml /opt/activemq/conf/activemq.xml
COPY postgresql-$POSTGRES_JDBC_DRIVER_VERSION.jar /opt/activemq/lib/postgresql-$POSTGRES_JDBC_DRIVER_VERSION.jar

WORKDIR $ACTIVEMQ_HOME

EXPOSE 61616
EXPOSE 8161

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bin/activemq console"]
