#!/usr/bin/env bash

. ./remoteInvocation.sh --source-only
. ./variable.sh --source-only


INITIAL_TPS=5000
BENCHMARK_COUNT=10
CURRENT_TPS=$INITIAL_TPS

SHORT_SLEEP=3
LONG_SLEEP=5

WAIT_AFTER_STOP_PRODUCER=30

PROJECT_DIR="/root/streaming-benchmarks"

CLEAN_LOAD_RESULT_CMD="rm *.load; rm -rf $PROJECT_DIR/$SPARK_DIR/work/*; rm -rf /root/kafka-logs/*;"
REBOOT_CMD="reboot;"
SHUTDOWN_CMD="shutdown;"
CLEAN_RESULT_CMD="cd $PROJECT_DIR; rm data/*.txt; rm -rf data/workers; rm -rf /root/zookeeper/version-2/*"

CLEAN_BUILD_BENCHMARK="cd $PROJECT_DIR; ./stream-bench.sh SETUP_BENCHMARK"
SETUP_KAFKA="cd $PROJECT_DIR; ./stream-bench.sh SETUP_KAFKA"

LOAD_START_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_LOAD;"
LOAD_STOP_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_LOAD;"

DELETE_TOPIC="cd $PROJECT_DIR/$KAFKA_DIR; ./bin/kafka-topics.sh --delete --bootstrap-server "$BOOTSTRAP_SERVERS" --topic $TOPIC;"
CREATE_TOPIC="cd $PROJECT_DIR/$KAFKA_DIR; ./bin/kafka-topics.sh --create --bootstrap-server "$BOOTSTRAP_SERVERS" --replication-factor 1 --partitions $PARTITIONS --topic $TOPIC;"

START_MONITOR_CPU="top -b -d 1 | grep --line-buffered Cpu > cpu.load;"
START_MONITOR_MEM="top -b -d 1 | grep --line-buffered 'MiB Mem' > mem.load;"
STOP_MONITOR="ps aux | grep top | awk {'print \$2'} | xargs sudo kill;"

START_FLINK_CMD="cd $PROJECT_DIR; ./$FLINK_DIR/bin/start-cluster.sh;"
STOP_FLINK_CMD="cd $PROJECT_DIR; ./$FLINK_DIR/bin/stop-cluster.sh;"
START_FLINK_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_FLINK_PROCESSING;"
STOP_FLINK_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_FLINK_PROCESSING;"

START_SPARK_CMD="cd $PROJECT_DIR/$SPARK_DIR; ./sbin/start-all.sh;"
STOP_SPARK_CMD="cd $PROJECT_DIR/$SPARK_DIR; ./sbin/stop-all.sh;"
START_SPARK_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_SPARK_PROCESSING;"
STOP_SPARK_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_SPARK_PROCESSING;"

START_ZK_CMD="cd $PROJECT_DIR/$KAFKA_DIR; ./bin/zookeeper-server-start.sh -daemon config/zookeeper.properties"
STOP_ZK_CMD="cd $PROJECT_DIR/$KAFKA_DIR; ./bin/zookeeper-server-stop.sh;"

START_KAFKA_CMD="cd $PROJECT_DIR/$KAFKA_DIR; ./bin/kafka-server-start.sh -daemon config/server.properties"
STOP_KAFKA_CMD="cd $PROJECT_DIR/$KAFKA_DIR; ./bin/kafka-server-stop.sh;"

CREATE_KAFKA_TOPIC="cd $PROJECT_DIR; ./stream-bench.sh CREATE_TOPIC;"

START_KAFKA_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_KAFKA_PROCESSING;"
STOP_KAFKA_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_KAFKA_PROCESSING;"

START_JET_CMD="cd $PROJECT_DIR; ./$HAZELCAST_DIR/bin/jet-start"
STOP_JET_CMD="cd $PROJECT_DIR; ./$HAZELCAST_DIR/bin/jet-stop"
START_JET_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_JET_PROCESSING;"
STOP_JET_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_JET_PROCESSING;"
START_JET_EMBEDDED_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_JET_EMBEDDED_PROCESSING;"
STOP_JET_EMBEDDED_PROC_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_JET_EMBEDDED_PROCESSING;"

START_REDIS_CMD="cd $PROJECT_DIR; ./stream-bench.sh START_REDIS;"
STOP_REDIS_CMD="cd $PROJECT_DIR; ./stream-bench.sh STOP_REDIS;"

PULL_GIT="cd $PROJECT_DIR; git reset --hard HEAD; git pull origin master;"

function runAllServers {
    runCommandStreamServers "${1}" "nohup"
    runCommandZKServers "${1}" "nohup"
    runCommandKafkaServers "${1}" "nohup"
    runCommandLoadServers "${1}" "nohup"
    runCommandRedisServer "${1}" "nohup"
}

function stopLoadData {
    echo "Main loaders stopping"
    runCommandLoadServers "${LOAD_STOP_CMD}" "nohup"
}

function startLoadData {
    echo "Main loaders starting"
    runCommandLoadServers "${LOAD_START_CMD}" "nohup"
}

function cleanKafka {
    echo "Deleted kafka topic"
    runCommandKafkaServer "${DELETE_TOPIC}"
    sleep ${SHORT_SLEEP}
    echo "Created kafka topic"
    runCommandKafkaServer "${CREATE_TOPIC}"
}

function startZK {
    echo "Starting Zookeepers"
    runCommandZKServers "${START_ZK_CMD}"
}

function stopZK {
    echo "Stopping Zookeepers"
    runCommandZKServers "${STOP_ZK_CMD}"
}

function startKafka {
    echo "Starting Kafka nodes"
    runCommandKafkaServers "${START_KAFKA_CMD}"
}

function stopKafka {
    echo "Stopping Kafka nodes"
    runCommandKafkaServers "${STOP_KAFKA_CMD}"
}

function cleanResult {
    echo "Cleaning previous benchmark result"
    runCommandStreamServers "${CLEAN_LOAD_RESULT_CMD}" "nohup"
    runCommandKafkaServers "${CLEAN_LOAD_RESULT_CMD}" "nohup"
    runCommandRedisServer "${CLEAN_RESULT_CMD}" "nohup"
    runCommandZKServers "${CLEAN_RESULT_CMD}" "nohup"
}

function startJet {
    echo "Starting Jet"
    runCommandStreamServers "${START_JET_CMD}" "nohup"
}

function stopJet {
    echo "Stopping Jet"
    runCommandStreamServers "${STOP_JET_CMD}"
}

function startJetProcessing {
    echo "Starting Jet Processing"
    runCommandMasterStreamServers "${START_JET_PROC_CMD}" "nohup"
}

function stopJetProcessing {
    echo "Stopping Jet Processing"
    runCommandMasterStreamServers "${STOP_JET_PROC_CMD}" "nohup"
 }

function startJetEmbeddedProcessing {
    echo "Starting Jet Processing"
    runCommandStreamServers "${START_JET_EMBEDDED_PROC_CMD}" "nohup"
}

function stopJetEmbeddedProcessing {
    echo "Stopping Jet Processing"
    runCommandStreamServers "${STOP_JET_EMBEDDED_PROC_CMD}" "nohup"
 }

function startFlink {
    echo "Starting Flink"
    runCommandMasterStreamServers "${START_FLINK_CMD}"
}

function stopFlink {
    echo "Stopping Flink"
    runCommandMasterStreamServers "${STOP_FLINK_CMD}"
}

function startFlinkProcessing {
    echo "Starting Flink Processing"
    runCommandMasterStreamServers "${START_FLINK_PROC_CMD}" "nohup"
}

function stopFlinkProcessing {
    echo "Stopping Flink Processing"
    runCommandMasterStreamServers "${STOP_FLINK_PROC_CMD}" "nohup"
 }

function startSpark {
    echo "Starting Spark"
    runCommandMasterStreamServers "${START_SPARK_CMD}"
}

function stopSpark {
    echo "Stopping Spark"
    runCommandMasterStreamServers "${STOP_SPARK_CMD}"
}

function startSparkProcessing {
    echo "Starting Spark processing"
    runCommandMasterStreamServers "${START_SPARK_PROC_CMD}" "nohup"
}

function stopSparkProcessing {
    echo "Stopping Spark processing"
    runCommandRedisServer "${STOP_SPARK_PROC_CMD}" "nohup"
}

function startKafkaProcessing {
    echo "Starting Kafka processing"
    runCommandStreamServers "${START_KAFKA_PROC_CMD}" "nohup"
}

function stopKafkaProcessing {
    echo "Stopping Kafka processing"
    runCommandStreamServers "${STOP_KAFKA_PROC_CMD}" "nohup"
}

function startMonitoring(){
    echo "Start Monitoring"
    runCommandStreamServers "${START_MONITOR_CPU}" "nohup"
    runCommandStreamServers "${START_MONITOR_MEM}" "nohup"
    runCommandKafkaServers "${START_MONITOR_CPU}" "nohup"
    runCommandKafkaServers "${START_MONITOR_MEM}" "nohup"
}

function stopMonitoring(){
    echo "Stop Monitoring"
    runCommandStreamServers "${STOP_MONITOR}" "nohup"
    runCommandKafkaServers "${STOP_MONITOR}" "nohup"
}

function changeTps(){
    runCommandLoadServers "sed -i \"/TPS=/c\TPS=$1\" ./streaming-benchmarks/variable.sh" "nohup"
}

function startRedis {
    echo "Starting Redis"
    runCommandRedisServer "${START_REDIS_CMD}" "nohup"
    sleep ${SHORT_SLEEP}
}

function stopRedis {
    echo "Stopping Redis"
    runCommandRedisServer "${STOP_REDIS_CMD}"
    sleep ${SHORT_SLEEP}
}


function prepareEnvironment(){
    cleanResult
    sleep ${SHORT_SLEEP}
    startZK
    sleep ${LONG_SLEEP}
    startKafka
    sleep ${LONG_SLEEP}
    cleanKafka
    startRedis
    sleep ${LONG_SLEEP}
}

function destroyEnvironment(){
    sleep ${SHORT_SLEEP}
    stopRedis
    stopKafka
    sleep ${SHORT_SLEEP}
    stopZK
}


function getBenchmarkResult(){
    ENGINE_PATH=${1}
    SUB_PATH=TPS_${CURRENT_TPS}_DURATION_${TEST_TIME}
    PATH_RESULT=result/${ENGINE_PATH}/${SUB_PATH}
    rm -rf ${PATH_RESULT};
    mkdir -p ${PATH_RESULT}
    getResultFromStreamServer "${PATH_RESULT}"
    getResultFromKafkaServer "${PATH_RESULT}"
    getResultFromRedisServer "${PATH_RESULT}"
    sleep ${SHORT_SLEEP}
    Rscript reporting/reporting.R ${ENGINE_PATH} ${INITIAL_TPS} ${TEST_TIME} ${BENCHMARK_COUNT}
}

function benchmark(){
    startMonitoring
    sleep ${LONG_SLEEP}
    startLoadData
    sleep ${TEST_TIME}
    stopLoadData
    sleep ${WAIT_AFTER_STOP_PRODUCER}
    stopMonitoring
}

function runSystem(){
    prepareEnvironment
    case $1 in
         jet_embedded)
            startJetEmbeddedProcessing
            benchmark $1
            sleep ${SHORT_SLEEP}
            stopJetEmbeddedProcessing
        ;;
         jet)
            startJet
            sleep ${SHORT_SLEEP}
            startJetProcessing
            benchmark $1
            sleep ${SHORT_SLEEP}
            stopJet
        ;;
        flink)
            startFlink
            sleep ${SHORT_SLEEP}
            startFlinkProcessing
            benchmark $1
            stopFlinkProcessing
            sleep ${SHORT_SLEEP}
            stopFlink
        ;;
        spark)
            startSpark
            sleep ${SHORT_SLEEP}
            startSparkProcessing
            benchmark $1
            stopSparkProcessing
            sleep ${SHORT_SLEEP}
            stopSpark
        ;;
        kafka)
            sleep ${LONG_SLEEP}
            startKafkaProcessing
            benchmark $1
            stopKafkaProcessing
            sleep ${SHORT_SLEEP}
        ;;
    esac
    destroyEnvironment
    getBenchmarkResult $1

}

function stopAll (){
    stopLoadData
    stopMonitoring
    stopKafkaProcessing
    stopJet
    stopFlinkProcessing
    stopFlink
    stopSparkProcessing
    stopSpark
    cleanKafka
    destroyEnvironment
    cleanResult
}

function benchmarkLoop (){
  for i in $(seq 1 $BENCHMARK_COUNT); do
      CURRENT_TPS=$((i * INITIAL_TPS))
      echo "Benchmark $CURRENT_TPS"
      runAllServers "${PULL_GIT}"
      sleep ${SHORT_SLEEP}
      changeTps $CURRENT_TPS
      runSystem "$1"
  done
}

case $1 in
    flink)
        benchmarkLoop "flink"
    ;;
    spark)
        benchmarkLoop "spark"
    ;;
    jet)
        benchmarkLoop "jet"
    ;;
    jet_embedded)
        benchmarkLoop "jet_embedded"
    ;;
    kafka)
        benchmarkLoop "kafka"
    ;;
    all)
        benchmarkLoop "flink"
        benchmarkLoop "kafka"
#        benchmarkLoop "spark"
#        benchmarkLoop "jet"
    ;;
    start)
        case $2 in
            flink)
                startFlink
            ;;
            spark)
                startSpark
            ;;
            process)
                startSparkProcessing
            ;;
            redis)
                startRedis
            ;;
            kafka)
                startKafka
            ;;
            zoo)
                startZK
            ;;
            prepare)
                prepareEnvironment
            ;;
            load)
                startLoadData
            ;;
        esac
    ;;
    stop)
        case $2 in
            flink)
                stopFlink
            ;;
            spark)
                stopSpark
            ;;
            process)
                stopSparkProcessing
            ;;
            zoo)
                stopZK
            ;;
            load)
                stopLoadData
            ;;
            redis)
                stopRedis
            ;;
            kafka)
                stopKafka
            ;;
            prepare)
                destroyEnvironment
            ;;
            all)
                stopAll
            ;;
        esac
    ;;
    load)
        startLoadData
    ;;
    push)
        git add --all
        git commit -am "$2"
        git push origin master
        runAllServers "${PULL_GIT}"
    ;;
    report)
        Rscript reporting.R
    ;;
    reboot)
        runAllServers "${REBOOT_CMD}"
    ;;
    shutdown)
        runAllServers "${SHUTDOWN_CMD}"
    ;;
    build)
        runCommandStreamServers "${CLEAN_BUILD_BENCHMARK}" "nohup"
    ;;
    clean)
        cleanResult
    ;;
    change)
        changeTps $2
    ;;
    result)
        getResultFromStreamServer "result/$1/TPS_4000_DURATION_600"
        getResultFromKafkaServer "result/$1/TPS_4000_DURATION_600"
        getResultFromRedisServer "result/$1/TPS_4000_DURATION_600"
    ;;
    test)
        runAllServers "${PULL_GIT}"
        runSystem $2
        #Rscript --vanilla reporting.R "spark" 1000 60
        #Rscript --vanilla reporting.R "flink" 1000 60
        echo "Please Enter valid command"


esac
