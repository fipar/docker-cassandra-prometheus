# docker build -t fipar/cassandra-pmm:v1 .
FROM cassandra:3.5

ENV CASSANDRA_CONFIG=/etc/cassandra

# install curl
RUN apt-get update && apt-get install -y curl
# install pmm-client
RUN apt-get -y install lsb-release wget; \
    wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb; \
    dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb; \
    apt-get update; \
    apt-get -y install pmm-client;

COPY configure-pmm-client.sh /usr/local/bin 

# authentication
RUN sed -i -e "s/^authenticator.*/authenticator: PasswordAuthenticator/" $CASSANDRA_CONFIG/cassandra.yaml

# prometheus (PROMETHEUS_PORT can be injected on runtime)
ADD http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.6/jmx_prometheus_javaagent-0.6.jar /usr/app/jmx_prometheus_javaagent.jar
ADD prometheus-config.yml /usr/app/prometheus-config.yml
RUN chmod +r /usr/app/jmx_prometheus_javaagent.jar && \
    echo 'JVM_OPTS="$JVM_OPTS -javaagent:/usr/app/jmx_prometheus_javaagent.jar=${PROMETHEUS_PORT:-7400}:/usr/app/prometheus-config.yml"' >> $CASSANDRA_CONFIG/cassandra-env.sh

