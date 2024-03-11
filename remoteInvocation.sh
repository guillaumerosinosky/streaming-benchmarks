#!/usr/bin/env bash

STREAM_SERVER_COUNT=10
LOAD_SERVER_COUNT=50
ZOOKEEPER_SERVER_COUNT=3
KAFKA_SERVER_COUNT=6
SSH_USER="root"

function runCommandStreamServers(){
    counter=1
    while [ ${counter} -le ${STREAM_SERVER_COUNT} ]
    do
        formatted_number=$(printf "%02d" $counter)
        if [ "$2" != "nohup" ]; then
            ssh -o StrictHostKeyChecking=no ${SSH_USER}@stream-node-"${formatted_number}" $1
        else
            nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@stream-node-"${formatted_number}" $1 &
        fi
        ((counter++))
    done
}

function runCommandMasterStreamServers(){
    if [ "$2" != "nohup" ]; then
        ssh -o StrictHostKeyChecking=no ${SSH_USER}@stream-node-01 $1
    else
        nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@stream-node-01 $1 &
    fi
}

function runCommandKafkaServer(){
    if [ "$2" != "nohup" ]; then
        ssh -o StrictHostKeyChecking=no ${SSH_USER}@kafka-node-01 $1
    else
        nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@kafka-node-01 $1 &
    fi
}

function runCommandKafkaServers(){
    counter=1
    while [ ${counter} -le ${KAFKA_SERVER_COUNT} ]
    do
        if [ "$2" != "nohup" ]; then
            ssh -o StrictHostKeyChecking=no ${SSH_USER}@kafka-node-0${counter} $1
        else
            nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@kafka-node-0${counter} $1 &
        fi
        ((counter++))
    done
}

function runCommandZKServers(){
    counter=1
    while [ ${counter} -le ${ZOOKEEPER_SERVER_COUNT} ]
    do
       if [ "$2" != "nohup" ]; then
           ssh -o StrictHostKeyChecking=no ${SSH_USER}@zookeeper-node-0${counter} $1
       else
           nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@zookeeper-node-0${counter} $1 &
       fi
       ((counter++))
    done
}

function runCommandLoadServers(){
    counter=1
    while [ ${counter} -le ${LOAD_SERVER_COUNT} ]
    do
        formatted_number=$(printf "%02d" $counter)
        if [ "$2" != "nohup" ]; then
            ssh -o StrictHostKeyChecking=no ${SSH_USER}@load-node-"${formatted_number}" $1
        else
            nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@load-node-"${formatted_number}" $1 &
        fi
        ((counter++))
    done
}

function runCommandRedisServer(){
    if [ "$2" != "nohup" ]; then
        ssh -o StrictHostKeyChecking=no ${SSH_USER}@redisdo $1
    else
        nohup ssh -o StrictHostKeyChecking=no ${SSH_USER}@redisdo $1 &
    fi
}

function getResultFromStreamServer(){
    counter=1
    while [ ${counter} -le ${STREAM_SERVER_COUNT} ]
    do
        formatted_number=$(printf "%02d" $counter)
        nohup scp -o StrictHostKeyChecking=no ${SSH_USER}@stream-node-"${formatted_number}":~/cpu.load $1/stream-node-"${formatted_number}".cpu &
        nohup scp -o StrictHostKeyChecking=no ${SSH_USER}@stream-node-"${formatted_number}":~/mem.load $1/stream-node-"${formatted_number}".mem &
        ((counter++))
    done
}

function getResultFromKafkaServer(){
    counter=1
    while [ ${counter} -le ${KAFKA_SERVER_COUNT} ]
    do
        nohup scp -o StrictHostKeyChecking=no ${SSH_USER}@kafka-node-0${counter}:~/cpu.load $1/kafka-node-0${counter}.cpu &
        nohup scp -o StrictHostKeyChecking=no ${SSH_USER}@kafka-node-0${counter}:~/mem.load $1/kafka-node-0${counter}.mem &
        ((counter++))
    done
}

function getResultFromRedisServer(){
    scp -o StrictHostKeyChecking=no ${SSH_USER}@redisdo:~/streaming-benchmarks/data/seen.txt $1/redis-seen.txt
    scp -o StrictHostKeyChecking=no ${SSH_USER}@redisdo:~/streaming-benchmarks/data/updated.txt $1/redis-updated.txt
}