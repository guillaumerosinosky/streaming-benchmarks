# Docker load testing

## Build

```bash
docker build -t test_clj .
```

## SUT deployment

### Apache Flink

```bash
cd flink-benchmarks
docker compose up
```

Build and deploy the JAR file in Apache Flink.

### Others

Not implemented this day.

## Run

Execute the load test (injection in Kafka).
Please launch in the same network as your SUT.

### Usage with [Flink Docker Compose](flink-benchmarks/docker-compose.yml)

See []().

```bash
docker run --rm --name test_clj --network alloy-test_default test_clj
```

### Specific usage

```bash
docker run --rm --name test_clj --network alloy-test_default -v $PWD/conf/composeConf.yaml:/usr/src/app/benchmarkConf.yaml test_clj lein run --configPath ./benchmarkConf.yaml -n
docker run --rm --name test_clj --network alloy-test_default -v $PWD/conf/composeConf.yaml:/usr/src/app/benchmarkConf.yaml test_clj lein run --configPath ./benchmarkConf.yaml -r -t 100
```

### Get results

```bash
docker run --rm --name test_clj --network alloy-test_default test_clj /usr/src/app/get_stats.sh
docker cp test_clj:/usr/src/app/seen.txt .
docker cp test_clj:/usr/src/app/updated.txt .
docker stop test_clj
```