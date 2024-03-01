#! /usr/bin/env bash


./stream-bench.sh SETUP
. ./variable.sh --source-only

#FLINK SETUP
sed -i 's/taskmanager.heap.mb: 1024/taskmanager.heap.mb: 6144/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml
sed -i 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: 4/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml
sed -i 's/jobmanager.rpc.address: localhost/jobmanager.rpc.address: stream-node-01/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml

sed -i 's/taskmanager.heap.mb: 6144/taskmanager.heap.mb: 15360/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml
sed -i 's/taskmanager.numberOfTaskSlots: 4/taskmanager.numberOfTaskSlots: 8/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml

sed -i 's/taskmanager.heap.mb: 15360/taskmanager.heap.mb: 30720/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml
sed -i 's/taskmanager.numberOfTaskSlots: 8/taskmanager.numberOfTaskSlots: 16/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml
sed -i 's/jobmanager.heap.mb: 1024/jobmanager.heap.mb: 15360/g' /root/stream-benchmarking/"${FLINK_DIR}"/conf/flink-conf.yaml

cp /dev/null /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
# shellcheck disable=SC2129
echo "stream-node-02" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-03" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-04" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-05" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-06" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-07" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-08" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-09" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers
echo "stream-node-10" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/workers


cp /dev/null /root/stream-benchmarking/"${FLINK_DIR}"/conf/masters
echo "stream-node-01" >> /root/stream-benchmarking/"${FLINK_DIR}"/conf/masters

#SPARK SETUP
cp /dev/null /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
# shellcheck disable=SC2129
echo "stream-node-02" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-03" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-04" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-05" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-06" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-07" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-08" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-09" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers
echo "stream-node-10" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/workers


cp /dev/null /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
# shellcheck disable=SC2129
echo "#!/usr/bin/env bash" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
echo "SPARK_DRIVER_MEMORY=30G" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
echo "SPARK_EXECUTOR_CORES=16" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
echo "SPARK_EXECUTOR_MEMORY=30G" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
echo "SPARK_WORKER_CORES=16" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
echo "SPARK_WORKER_MEMORY=30g" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
echo "SPARK_DAEMON_MEMORY=30g" >> /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh
chmod +x /root/stream-benchmarking/"${SPARK_DIR}"/conf/spark-env.sh

##STORM SETUP
#cp /dev/null /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
## shellcheck disable=SC2129
#echo "storm.zookeeper.servers:" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "    - \"zookeeper-node-01\"" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "    - \"zookeeper-node-02\"" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "    - \"zookeeper-node-03\"" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "storm.zookeeper.port: 2181" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "nimbus.childopts: \"-Xmx3g\"" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "nimbus.seeds: [\"stream-node-01\"]" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "supervisor.childopts: \"-Xmx1g -Djava.net.preferIPv4Stack=true]\"" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#echo "worker.childopts: \"-Xmx1g -Djava.net.preferIPv4Stack=true\"" >> /root/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#

#KAFKA SETUP
sed -i 's/zookeeper.connect=localhost:2181/zookeeper.connect=zookeeper-node-01:2181,zookeeper-node-02:2181,zookeeper-node-03:2181/g' /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/server.properties

sed -i 's/maxClientCnxns=0/maxClientCnxns=0/g' /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
# shellcheck disable=SC2129
echo "tickTime=2000" >> /root/stream-benchmarking/"${KAFKA_DIR}"/config/zookeeper.properties
echo "initLimit=20" >> /root/stream-benchmarking/"${KAFKA_DIR}"/config/zookeeper.properties
echo "syncLimit=10" >> /root/stream-benchmarking/"${KAFKA_DIR}"/config/zookeeper.properties
echo "server.1=zookeeper-node-01:2888:3888" >> /root/stream-benchmarking/"${KAFKA_DIR}"/config/zookeeper.properties
echo "server.2=zookeeper-node-02:2888:3888" >> /root/stream-benchmarking/"${KAFKA_DIR}"/config/zookeeper.properties
echo "server.3=zookeeper-node-03:2888:3888" >> /root/stream-benchmarking/"${KAFKA_DIR}"/config/zookeeper.properties

mkdir /tmp/zookeeper/ -p
touch /tmp/zookeeper/myid
echo '1' >> /tmp/zookeeper/myid



sed -i 's/maxClientCnxns=0/maxClientCnxns=0/g' /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
# shellcheck disable=SC2129
echo "tickTime=2000" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
echo "initLimit=20" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
echo "syncLimit=10" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
echo "dataDir=/root/zookeeper" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
echo "server.1=zookeeper-node-01:2888:3888" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
echo "server.2=zookeeper-node-02:2888:3888" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties
echo "server.3=zookeeper-node-03:2888:3888" >> /root/stream-benchmarking/"${KAFKA_STREAM_DIR}"/config/zookeeper.properties

mkdir /root/zookeeper/ -p
touch /root/zookeeper/myid
echo '1' >> /root/zookeeper/myid

#JSTORM setup

#install 2.4.0 jar to maven repo
mvn install:install-file -Dfile=/root/stream-benchmarking/jstorm-2.4.0/jstorm-core-2.4.0.jar -DgroupId=com.alibaba.jstorm -DartifactId=jstorm-core -Dversion=2.4.0 -Dpackaging=jar

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
#
#
#
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-01:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-02:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-03:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-04:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-05:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-06:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-07:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-08:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-09:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node-10:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml
#scp "${STORM_DIR}"/conf/storm.yaml ubuntu@stream-node11:~/stream-benchmarking/"${STORM_DIR}"/conf/storm.yaml



