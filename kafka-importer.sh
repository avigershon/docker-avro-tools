#!/bin/bash

DIRECTORY="$1"

for file in $(find $DIRECTORY -name "*.avro")
do
      echo "Processing file $(basename "${file}") ..."
      java -jar /usr/share/java/avro-tools-1.7.7.jar getschema "${file}" > "${file}".avsc
      java -jar /usr/share/java/avro-tools-1.7.7.jar tojson "${file}" > "${file}".json

      /usr/bin/kafka-avro-console-producer \
        --broker-list v1-cp-kafka:9092 --topic source_file_DW_DIM_AuditStatusHistory \
        --property schema.registry.url=http://v1-cp-schema-registry:8081 \
        --property value.schema="$(< "${file}".avsc)" < "${file}".json

      mv "${file}" "${file}".done
done
