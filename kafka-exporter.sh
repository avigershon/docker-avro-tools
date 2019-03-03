#!/bin/bash

MINIO_URL="$1"
TOPIC_PREFIX="$2"

for topic in $(/usr/bin/kafka-topics  --list --zookeeper v1-cp-zookeeper:2181  | grep  $TOPIC_PREFIX)
do
      echo "Exporting topic ${topic} ..."

      curl -X PUT \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -d '{
        "connector.class": "io.confluent.connect.s3.S3SinkConnector",
        "schema.compatibility": "FULL",
        "flush.size": "6",
        "topics": "'${topic}'",
        "tasks.max": "1",
        "s3.part.size": "5242880",
        "store.url": "'$MINIO_URL'",
        "format.class": "io.confluent.connect.s3.format.avro.AvroFormat",
        "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
        "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
        "storage.class": "io.confluent.connect.s3.storage.S3Storage",
        "s3.bucket.name": "kafka-bucket"
      }' http://v1-cp-kafka-connect:8083/connectors/${topic}-s3-sink/config

done
