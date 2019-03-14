#!/bin/bash

MINIO_URL="$1"
PREFIX="$2"

TOPIC_PREFIX="^${PREFIX}\+\.[A-Za-z0-9]\+\.[A-Za-z0-9]\+" #"$2"

for topic in $(/usr/bin/kafka-topics  --list --zookeeper v1-cp-zookeeper:2181  | grep  $TOPIC_PREFIX)
do
      echo "Exporting topic ${topic} ..."

      str=$topic
      delimiter=.
      s=$str$delimiter
      array=();
      while [[ $s ]]; do
          array+=( "${s%%"$delimiter"*}" );
          s=${s#*"$delimiter"};
      done;

      if [ $(echo ${array[0]} | cut -c1-2) = "__" ]; then

        echo "System topic - aborting..."

      else

        echo "Creating S3 sink connector to bucket ${array[0]}"

        curl -X PUT \
          -H 'Content-Type: application/json' \
          -H 'Accept: application/json' \
          -d '{
          "connector.class": "io.confluent.connect.s3.S3SinkConnector",
          "schema.compatibility": "NONE",
          "flush.size": "6",
          "topics": "'${topic}'",
          "tasks.max": "1",
          "s3.part.size": "5242880",
          "store.url": "'$MINIO_URL'",
          "format.class": "io.confluent.connect.s3.format.avro.AvroFormat",
          "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
          "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
          "storage.class": "io.confluent.connect.s3.storage.S3Storage",
          "value.converter.schemas.enable": true,
          "value.converter": "org.apache.kafka.connect.json.JsonConverter",
          "s3.bucket.name": "'${array[0]}'"
        }' http://v1-cp-kafka-connect:8083/connectors/${topic}.s3.sink/config

      fi
done
