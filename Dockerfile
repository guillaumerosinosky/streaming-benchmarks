FROM clojure:lein
COPY data /usr/src/app
# default conf
COPY conf/composeConf.yaml /usr/src/app/benchmarkConf.yaml
WORKDIR /usr/src/app
RUN lein deps

COPY run_test.sh /usr/src/app
COPY get_stats.sh /usr/src/app

# Init Redis & launch
CMD ["sh", "-c", "/usr/src/app/run_test.sh"]