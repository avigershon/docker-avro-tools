#!/bin/bash

DIRECTORY="$1"
emptyString=""

for file in $(find $DIRECTORY -name "*.avro")
do
    if [ ! -f $file ]; then
      echo "File already been processed"
    else
      topic=$(echo ${file/$DIRECTORY/$emptyString} | cut -d"/" -f1)
      echo "Loading file $(basename "${file}") to topic ${topic}..."
      java -jar /usr/share/java/avro-tools-1.7.7.jar getschema "${file}" > "${file}".avsc
      java -jar /usr/share/java/avro-tools-1.7.7.jar tojson "${file}" > "${file}".json

      /usr/bin/kafka-avro-console-producer \
        --broker-list v1-cp-kafka:9092 --topic replicated-${topic} \
        --property schema.registry.url=http://v1-cp-schema-registry:8081 \
        --property value.schema="$(< "${file}".avsc)" < "${file}".json

      mv "${file}" "${file}".done
    fi
done
