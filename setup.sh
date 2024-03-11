#! /usr/bin/env bash
. ./variable.sh --source-only

function flink_setup() {
    PRIVATE_IP=$(ip addr show eth1 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    PUBLIC_IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -1)

    # shellcheck disable=SC2016
    sed -i '/jobmanager.rpc.address/c\jobmanager.rpc.address: stream-node-01' /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml
    sed -i '/jobmanager.heap.mb/c\jobmanager.heap.mb: 15360' /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml
    sed -i "/jobmanager.bind-host/c\jobmanager.bind-host: 0.0.0.0" /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml

    sed -i "/rest.bind-address/c\rest.bind-address: 0.0.0.0" /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml

    sed -i "/taskmanager.bind-host:/c\taskmanager.bind-host: ${PRIVATE_IP}" /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml
    sed -i "/taskmanager.host:/c\taskmanager.host: ${PRIVATE_IP}" /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml
    sed -i '/taskmanager.heap.mb/c\taskmanager.heap.mb: 15360' /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml
    sed -i "/taskmanager.numberOfTaskSlots/c\taskmanager.numberOfTaskSlots: 72" /root/streaming-benchmarks/"${FLINK_DIR}"/conf/flink-conf.yaml

    cp /dev/null /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    # shellcheck disable=SC2129
    echo "stream-node-02" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-03" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-04" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-05" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-06" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-07" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-08" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-09" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers
    echo "stream-node-10" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/workers


    cp /dev/null /root/streaming-benchmarks/"${FLINK_DIR}"/conf/masters
    echo "stream-node-01" >> /root/streaming-benchmarks/"${FLINK_DIR}"/conf/masters
}

function spark_setup() {
    cp /dev/null /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    # shellcheck disable=SC2129
    echo "stream-node-02" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-03" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-04" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-05" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-06" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-07" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-08" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-09" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers
    echo "stream-node-10" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/workers

    PRIVATE_IP=$(ip addr show eth1 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    cp /dev/null /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    # shellcheck disable=SC2129
    echo "#!/usr/bin/env bash" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_MASTER_HOST=${PRIVATE_IP}" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_DRIVER_MEMORY=15G" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_EXECUTOR_CORES=8" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_WORKER_DIR=/root/streaming-benchmarks/spark-3.5.1-bin-hadoop3/work" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_EXECUTOR_MEMORY=15G" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_WORKER_CORES=8" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_WORKER_MEMORY=15g" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    echo "SPARK_DAEMON_MEMORY=15g" >> /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh
    chmod +x /root/streaming-benchmarks/"${SPARK_DIR}"/conf/spark-env.sh

}

function kafka_setup() {
    #KAFKA SETUP
    PRIVATE_IP=$(ip addr show eth1 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    mkdir /root/kafka-logs/ -p
    rm -rf /root/kafka-logs/*
    sed -i 's/zookeeper.connect=localhost:2181/zookeeper.connect=zookeeper-node-01:2181,zookeeper-node-02:2181,zookeeper-node-03:2181/g' /root/streaming-benchmarks/"${KAFKA_DIR}"/config/server.properties
    sed -i "/broker.id/c\broker.id=${HOSTNAME: -1}" /root/streaming-benchmarks/"${KAFKA_DIR}"/config/server.properties
    sed -i "/log.dirs=\/tmp\/kafka-logs/c\log.dirs=/root/kafka-logs" /root/streaming-benchmarks/"${KAFKA_DIR}"/config/server.properties
    sed -i "/advertised.listeners/c\advertised.listeners=PLAINTEXT://${HOSTNAME}:9092" /root/streaming-benchmarks/"${KAFKA_DIR}"/config/server.properties
}

function zookeeper_setup() {
    # ZOOKEEPER SETUP
    : > /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties

    # shellcheck disable=SC2129
    echo 'maxClientCnxns=0' >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "tickTime=2000" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "initLimit=20" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "syncLimit=10" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "clientPort=2181" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "admin.enableServer=false" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "dataDir=/root/zookeeper" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties

    mkdir /root/zookeeper/ -p
    rm -rf /root/zookeeper/*
    touch /root/zookeeper/myid
    echo "${HOSTNAME: -1}" >> /root/zookeeper/myid

    # shellcheck disable=SC2129
    echo "server.1=zookeeper-node-01:2888:3888" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "server.2=zookeeper-node-02:2888:3888" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
    echo "server.3=zookeeper-node-03:2888:3888" >> /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties

    sed -i "s/${HOSTNAME}/0.0.0.0/g" /root/streaming-benchmarks/"${KAFKA_DIR}"/config/zookeeper.properties
}

case $1 in
    "flink")
        flink_setup
        ;;
    "spark")
        spark_setup
        ;;
    "kafka")
        kafka_setup
        ;;
    "zookeeper")
        zookeeper_setup
        ;;
    *)
        echo "Invalid argument"
        ;;
esac



##Spark
#./sbin/start-master.sh -h stream-node-01 -p 7077
#./sbin/start-slave.sh spark://stream-node-01:7077
#
#
##Run zookeeper
#./bin/zookeeper-server-start.sh config/zookeeper.properties
#./bin/zookeeper-server-start.sh -daemon config/zookeeper.properties;
#
##Run kafka server
#./bin/kafka-server-start.sh config/server.properties
#./bin/kafka-server-start.sh -daemon config/server.properties;tail -100f logs/kafkaServer.out
#./bin/kafka-server-stop.sh
##List kafka topic
#./bin/kafka-topics.sh --list --zookeeper zookeeper-node-01:2181,zookeeper-node-02:2181,zookeeper-node-03:2181
#
#
##Create Kafka topic
#./bin/kafka-topics.sh --delete --zookeeper zookeeper-node-01:2181,zookeeper-node-02:2181,zookeeper-node-03:2181 --topic ad-events
#./bin/kafka-topics.sh --create --zookeeper zookeeper-node-01:2181,zookeeper-node-02:2181,zookeeper-node-03:2181 --replication-factor 1 --partitions 100 --topic ad-events
#./bin/kafka-topics.sh --create --zookeeper zookeeper-node-01:2181,zookeeper-node-02:2181,zookeeper-node-03:2181 --replication-factor 1 --partitions 4 --topic sample-test
#
#./bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ad-events
#./bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic ad-events
#
##Producer
#./bin/kafka-console-producer.sh --broker-list  kafka-node-01:9092,kafka-node-02:9092,kafka-node-03:9092,kafka-node-04:9092 --topic sample-test
#
##Consumer
#./bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic ad-events


