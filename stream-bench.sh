#!/bin/bash
# Copyright 2015, Yahoo Inc.
# Licensed under the terms of the Apache License 2.0. Please see LICENSE file in the project root for terms.
set -o pipefail
set -o errtrace
set -o nounset
set -o errexit

LEIN=${LEIN:-lein}
MVN=${MVN:-mvn}
GIT=${GIT:-git}
MAKE=${MAKE:-make}

. ./variable.sh --source-only

TEST_TPS=${TEST_TPS:-10}


pid_match() {
   local VAL=`ps -aef | grep "$1" | grep -v grep | awk '{print $2}'`
   echo $VAL
}

start_if_needed() {
  local match="$1"
  shift
  local name="$1"
  shift
  local sleep_time="$1"
  shift
  local PID=`pid_match "$match"`

  if [[ "$PID" -ne "" ]];
  then
    echo "$name is already running..."
  else
    "$@" &
    sleep $sleep_time
  fi
}

stop_if_needed() {
  local match="$1"
  local name="$2"
  local PID=`pid_match "$match"`
  if [[ "$PID" -ne "" ]];
  then
    kill "$PID"
    sleep 1
    local CHECK_AGAIN=`pid_match "$match"`
    if [[ "$CHECK_AGAIN" -ne "" ]];
    then
      kill -9 "$CHECK_AGAIN"
    fi
  else
    echo "No $name instance found to stop"
  fi
}

fetch_untar_file() {
  local FILE="download-cache/$1"
  local URL=$2
  if [[ -e "$FILE" ]];
  then
    echo "Using cached File $FILE"
  else
	mkdir -p download-cache/
    WGET=`which wget`
    CURL=`whereis curl`
    if [ -n "$WGET" ];
    then
      wget -O "$FILE" "$URL"
    elif [ -n "$CURL" ];
    then
      curl -o "$FILE" "$URL"
    else
      echo "Please install curl or wget to continue.";
      exit 1
    fi
  fi

  tar -xzvf "$FILE"
}

create_kafka_topic() {
    local count=`$KAFKA_DIR/bin/kafka-topics.sh --describe --bootstrap-server "$BOOTSTRAP_SERVERS" --topic ${TOPIC} 2>/dev/null | grep -c "does not exist"`
    if [[ "$count" = "1" ]];
    then
        $KAFKA_DIR/bin/kafka-topics.sh --create --bootstrap-server "$BOOTSTRAP_SERVERS" --replication-factor 1 --partitions ${PARTITIONS} --topic ${TOPIC}
    else
        echo "Kafka topic $TOPIC already exists"
    fi
}

run() {
  OPERATION=$1
  if [ "SETUP" = "$OPERATION" ];
  then
    run "SETUP_BENCHMARK"
	  run "SETUP_REDIS"
    run "SETUP_KAFKA"
    run "SETUP_KAFKA_STREAM"
    run "SETUP_HAZELCAST"
    run "SETUP_FLINK"
    run "SETUP_SPARK"
  elif [ "SETUP_BENCHMARK" = "$OPERATION" ];
  then
    $MVN clean install \
      -Dspark.version="$SPARK_VERSION" \
      -Dkafka.version="$KAFKA_VERSION" \
      -Dkafka.stream.version="$KAFKA_VERSION" \
      -Dhazelcast.version="$HAZELCAST_VERSION" \
      -Dflink.version="$FLINK_VERSION" \
      -Dscala.binary.version="$SCALA_BIN_VERSION" \
      -Dscala.version="$SCALA_BIN_VERSION.$SCALA_SUB_VERSION"
  elif [ "SETUP_REDIS" = "$OPERATION" ];
  then
    #Fetch and build Redis
    REDIS_FILE="$REDIS_DIR.tar.gz"
    echo "$REDIS_FILE"
    fetch_untar_file "$REDIS_FILE" "http://download.redis.io/releases/$REDIS_FILE"
    cd "$REDIS_DIR"
    $MAKE
    cd ..
  elif [ "SETUP_KAFKA" = "$OPERATION" ];
  then
    #Fetch Kafka
    KAFKA_FILE="$KAFKA_DIR.tgz"
    echo "$KAFKA_FILE"
    fetch_untar_file "$KAFKA_FILE" "$APACHE_MIRROR/kafka/$KAFKA_VERSION/$KAFKA_FILE"
  elif [ "SETUP_FLINK" = "$OPERATION" ];
  then
    
    #Fetch Flink
    FLINK_FILE="$FLINK_DIR-bin-scala_${SCALA_BIN_VERSION_12}.tgz"
    fetch_untar_file "$FLINK_FILE" "$APACHE_MIRROR/flink/flink-$FLINK_VERSION/$FLINK_FILE"
  elif [ "SETUP_SPARK" = "$OPERATION" ];
  then
    
    #Fetch Spark
    SPARK_FILE="$SPARK_DIR.tgz"
    fetch_untar_file "$SPARK_FILE" "$APACHE_MIRROR/spark/spark-$SPARK_VERSION/$SPARK_FILE"
  elif [ "SETUP_HAZELCAST" = "$OPERATION" ];
  then
    #Fetch Hazelcast
    HAZELCAST_FILE="$HAZELCAST_DIR.tar.gz"
    fetch_untar_file "$HAZELCAST_FILE" "https://github.com/hazelcast/hazelcast-jet/releases/download/v$HAZELCAST_VERSION/$HAZELCAST_FILE"
  elif [ "START_ZK" = "$OPERATION" ];
  then
    start_if_needed zookeeper ZooKeeper 10 $KAFKA_DIR/bin/zookeeper-server-start.sh -daemon $KAFKA_DIR/config/zookeeper.properties
  elif [ "STOP_ZK" = "$OPERATION" ];
  then
    stop_if_needed zookeeper ZooKeeper
    rm -rf /tmp/zookeeper
  elif [ "START_REDIS" = "$OPERATION" ];
  then
    PRIVATE_IP=$(ip addr show eth1 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    start_if_needed redis-server Redis 1 "$REDIS_DIR/src/redis-server" --bind $PRIVATE_IP 127.0.0.1 --protected-mode no
    cd data
    $LEIN run -n --configPath ../$CONF_FILE
    cd ..
  elif [ "LOAD_FROM_REDIS" = "$OPERATION" ];
  then
    cd data
    $LEIN run -g --configPath ../$CONF_FILE || true
    cd ..
  elif [ "STOP_REDIS" = "$OPERATION" ];
  then
    cd data
    $LEIN run -g --configPath ../$CONF_FILE || true
    cd ..
    stop_if_needed redis-server Redis
    rm -f dump.rdb
  elif [ "START_KAFKA" = "$OPERATION" ];
  then
    start_if_needed kafka\.Kafka Kafka 10 "$KAFKA_DIR/bin/kafka-server-start.sh" "$KAFKA_DIR/config/server.properties"
    create_kafka_topic
  elif [ "STOP_KAFKA" = "$OPERATION" ];
  then
    stop_if_needed kafka\.Kafka Kafka
    rm -rf /tmp/kafka-logs/
  elif [ "START_FLINK" = "$OPERATION" ];
  then
    start_if_needed org.apache.flink.runtime.jobmanager.JobManager Flink 1 ${FLINK_DIR}/bin/start-cluster.sh
  elif [ "STOP_FLINK" = "$OPERATION" ];
  then
    "${FLINK_DIR}"/bin/stop-cluster.sh
  elif [ "START_JET" = "$OPERATION" ];
  then
    start_if_needed HazelcastJet HazelcastJet 1 ${HAZELCAST_DIR}/bin/jet-start
  elif [ "STOP_JET" = "$OPERATION" ];
  then
    ${HAZELCAST_DIR}/bin/jet-stop
  elif [ "START_SPARK" = "$OPERATION" ];
  then
    start_if_needed org.apache.spark.deploy.master.Master SparkMaster 5 $SPARK_DIR/sbin/start-master.sh -h localhost -p 7077
    start_if_needed org.apache.spark.deploy.worker.Worker SparkWorker 5 $SPARK_DIR/sbin/start-worker.sh spark://localhost:7077
  elif [ "STOP_SPARK" = "$OPERATION" ];
  then
    stop_if_needed org.apache.spark.deploy.master.Master SparkMaster
    stop_if_needed org.apache.spark.deploy.worker.Worker SparkWorker
    sleep 3
  elif [ "START_LOAD" = "$OPERATION" ];
  then
    cd data
    start_if_needed leiningen.core.main "Load Generation" 1 $LEIN run -r -t $2 --configPath ../$CONF_FILE
    cd ..
  elif [ "STOP_LOAD" = "$OPERATION" ];
  then
    stop_if_needed leiningen.core.main "Load Generation"
  elif [ "START_SPARK_PROCESSING" = "$OPERATION" ];
  then
    "$SPARK_DIR/bin/spark-submit" --class spark.benchmark.AdvertisingSpark ./spark-benchmarks/target/spark-benchmarks-0.1.0.jar "$CONF_FILE" &
    sleep 5
  elif [ "STOP_SPARK_PROCESSING" = "$OPERATION" ];
  then
    stop_if_needed spark.benchmark.AdvertisingSpark "Spark Client Process"
  elif [ "START_KAFKA_PROCESSING" = "$OPERATION" ];
  then
    java -Xms3G -Xmx15G -jar ./kafka-benchmarks/target/kafka-benchmarks-0.1.0.jar -conf $CONF_FILE &
    sleep 3
  elif [ "STOP_KAFKA_PROCESSING" = "$OPERATION" ];
  then
    stop_if_needed kafka-benchmarks kafka-benchmarks
    rm -rf /tmp/kafka-streams/
  elif [ "START_FLINK_PROCESSING" = "$OPERATION" ];
  then
    "$FLINK_DIR/bin/flink" run ./flink-benchmarks/target/flink-benchmarks-0.1.0.jar --confPath $CONF_FILE &
    sleep 3
  elif [ "STOP_FLINK_PROCESSING" = "$OPERATION" ];
  then
    FLINK_ID=`"$FLINK_DIR/bin/flink" list | grep 'Flink Streaming Job' | awk '{print $4}'; true`
    if [ "$FLINK_ID" == "" ];
	then
	  echo "Could not find streaming job to kill"
    else
      "$FLINK_DIR/bin/flink" cancel $FLINK_ID
      sleep 3
    fi
  elif [ "START_JET_PROCESSING" = "$OPERATION" ];
  then
    start_if_needed HazelcastJetProcessing "Hazelcast Jet Processing" 3 "$HAZELCAST_DIR/bin/jet" submit ./hazelcast-benchmarks/target/hazelcast-benchmarks-0.1.0.jar -conf $CONF_FILE
    sleep 3
  elif [ "START_JET_EMBEDDED_PROCESSING" = "$OPERATION" ];
  then
    java -Xms3G -Xmx15G -jar ./hazelcast-benchmarks/target/hazelcast-benchmarks-0.1.0.jar -conf $CONF_FILE &
    sleep 3
  elif [ "STOP_JET_EMBEDDED_PROCESSING" = "$OPERATION" ];
  then
    stop_if_needed hazelcast-benchmarks hazelcast-benchmarks
    rm -rf /tmp/kafka-streams/
  elif [ "FLINK_TEST" = "$OPERATION" ];
  then
    run "START_ZK"
    run "START_REDIS"
    run "START_KAFKA"
    run "START_FLINK"
    run "START_FLINK_PROCESSING"
    run "START_LOAD" $TEST_TPS
    sleep ${TEST_TIME}
    run "STOP_LOAD"
    run "STOP_FLINK_PROCESSING"
    run "STOP_FLINK"
    run "STOP_KAFKA"
    run "STOP_REDIS"
    run "STOP_ZK"
  elif [ "JET_TEST" = "$OPERATION" ];
  then
    run "START_ZK"
    run "START_REDIS"
    run "START_KAFKA"
    run "START_JET"
    run "START_JET_PROCESSING"
    run "START_LOAD" $TEST_TPS
    sleep ${TEST_TIME}
    run "STOP_LOAD"
    run "STOP_JET"
    run "STOP_KAFKA"
    run "STOP_REDIS"
    run "STOP_ZK"
  elif [ "SPARK_TEST" = "$OPERATION" ];
  then
    run "START_ZK"
    run "START_REDIS"
    run "START_KAFKA"
    run "START_SPARK"
    run "START_SPARK_PROCESSING"
    run "START_LOAD" $TEST_TPS
    sleep ${TEST_TIME}
    run "STOP_LOAD"
    run "STOP_SPARK_PROCESSING"
    run "STOP_SPARK"
    run "STOP_KAFKA"
    run "STOP_REDIS"
    run "STOP_ZK"
  elif [ "KAFKA_TEST" = "$OPERATION" ];
  then
    run "START_ZK"
    run "START_REDIS"
    run "START_KAFKA"
    run "START_KAFKA_PROCESSING"
    run "START_LOAD" $TEST_TPS
    sleep ${TEST_TIME}
    run "STOP_LOAD"
    run "STOP_KAFKA_PROCESSING"
    run "STOP_KAFKA"
    run "STOP_REDIS"
    run "STOP_ZK"
  elif [ "STOP_ALL" = "$OPERATION" ];
  then
    run "START_ZK"
    run "STOP_LOAD"
    run "STOP_SPARK_PROCESSING"
    run "STOP_SPARK"
    run "STOP_JET"
    run "STOP_FLINK_PROCESSING"
    run "STOP_FLINK"
    run "STOP_KAFKA_PROCESSING"
    run "STOP_KAFKA"
    run "STOP_REDIS"
    run "STOP_ZK"
  else
    if [ "HELP" != "$OPERATION" ];
    then
      echo "UNKOWN OPERATION '$OPERATION'"
      echo
    fi
    echo "Supported Operations:"
    echo "SETUP: download and setup dependencies for running a single node test"
    echo "START_ZK: run a single node ZooKeeper instance on local host in the background"
    echo "STOP_ZK: kill the ZooKeeper instance"
    echo "START_REDIS: run a redis instance in the background"
    echo "STOP_REDIS: kill the redis instance"
    echo "START_JET: run Hazelcast Jet in the background"
    echo "STOP_JET: kill Hazelcast Jet"
    echo "START_KAFKA: run kafka in the background"
    echo "STOP_KAFKA: kill kafka"
    echo "START_LOAD: run kafka load generation"
    echo "STOP_LOAD: kill kafka load generation"
    echo "START_FLINK: run flink processes"
    echo "STOP_FLINK: kill flink processes"
    echo "START_SPARK: run spark processes"
    echo "STOP_SPARK: kill spark processes"
    echo
    echo "START_FLINK_PROCESSING: run the flink test processing"
    echo "STOP_FLINK_PROCESSING: kill the flink test processing"
    echo "START_KAFKA_PROCESSING: run the kafka test processing"
    echo "STOP_KAFKA_PROCESSING: kill the kafka test processing"
    echo "STOP_JET_PROCESSING: kill the Hazelcast Jet test processing"
    echo "START_JET_PROCESSING: run the Hazelcast Jet test processing"
    echo "START_SPARK_PROCESSING: run the spark test processing"
    echo "STOP_SPARK_PROCESSING: kill the spark test processing"
    echo
    echo "FLINK_TEST: run Flink test (assumes SETUP is done)"
    echo "SPARK_TEST: run Spark test (assumes SETUP is done)"
    echo "KAFKA_TEST: run Kafka test (assumes SETUP is done)"
    echo "JET_TEST: run Hazelcast test (assumes SETUP is done)"
    echo "STOP_ALL: stop everything"
    echo
    echo "HELP: print out this message"
    echo
    exit 1
  fi
}

if [ $# -lt 1 ];
then
  run "HELP"
else
  while [ $# -gt 0 ];
  do
    run "$1"
    shift
  done
fi
