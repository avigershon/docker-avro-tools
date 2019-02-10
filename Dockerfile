FROM dockerfile/java:oracle-java8
MAINTAINER coderfi@gmail.com

ENV JQ_VERSION='1.5'

RUN wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/jq-release.key -O /tmp/jq-release.key && \
    wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VERSION}/jq-linux64.asc -O /tmp/jq-linux64.asc && \
    wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /tmp/jq-linux64 && \
    gpg --import /tmp/jq-release.key && \
    gpg --verify /tmp/jq-linux64.asc /tmp/jq-linux64 && \
    cp /tmp/jq-linux64 /usr/bin/jq && \
    chmod +x /usr/bin/jq && \
    rm -f /tmp/jq-release.key && \
    rm -f /tmp/jq-linux64.asc && \
    rm -f /tmp/jq-linux64
    
ENV AVRO_VERSION 1.7.7
ENV AVRO_TOOLS_JAR /usr/share/java/avro-tools-${AVRO_VERSION}.jar

RUN mkdir -p /share \
 && cd /usr/share/java \
 && wget http://mirrors.gigenet.com/apache/avro/avro-${AVRO_VERSION}/java/avro-tools-${AVRO_VERSION}.jar

WORKDIR /share

ADD avro-tools-runner /usr/local/bin/avro-tools-runner
ENTRYPOINT ["avro-tools-runner"]

CMD ["--help"]
