FROM confluentinc/cp-kafka-connect:5.0.1
MAINTAINER coderfi@gmail.com

ENV AVRO_VERSION 1.7.7
ENV AVRO_TOOLS_JAR /usr/share/java/avro-tools-${AVRO_VERSION}.jar

RUN mkdir -p /share \
 && cd /usr/share/java \
 && wget http://mirrors.gigenet.com/apache/avro/avro-${AVRO_VERSION}/java/avro-tools-${AVRO_VERSION}.jar
 && wget https://dl.minio.io/client/mc/release/linux-amd64/mc -P /usr/bin/
 && chmod +x /usr/bin/mc

WORKDIR /share

ADD avro-tools-runner /usr/local/bin/avro-tools-runner
ADD job.sh /usr/local/bin/job.sh
ADD kafka-exporter.sh /usr/local/bin/kafka-exporter.sh
ADD kafka-importer.sh /usr/local/bin/kafka-importer.sh

RUN chmod +x /usr/local/bin/job.sh
RUN chmod +x /usr/local/bin/kafka-exporter.sh
RUN chmod +x /usr/local/bin/kafka-importer.sh

ENTRYPOINT ["avro-tools-runner"]

CMD ["--help"]
