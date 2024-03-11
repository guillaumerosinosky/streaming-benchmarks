#!/usr/bin/env Rscript
library(ggplot2)
library(scales)
library(dplyr)
library(grid)

theme_set(theme_bw())
options("scipen"=10)
args <- commandArgs(TRUE)
engines_all <- c("flink", "kafka", "spark")
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/util.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/StreamServerReport.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/KafkaServerReport.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/BenchmarkResult.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/BenchmarkPercentile.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/ResourceConsumptionReport.r')
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


#generateBenchmarkPercentile("kafka", init_tps, duration, 15)

if(length(args) == 0){
  tps_count <- 10
  tps <- 2000
  duration <- 600
  for (i in seq_along(engines_all)) {
    generateBenchmarkReport(engines_all[i], tps, duration, tps_count)
    generateStreamServerLoadReport(engines_all[i], tps, duration, tps_count)
    generateKafkaServerLoadReport(engines_all[i], tps, duration, tps_count)
    generateBenchmarkPercentile(engines_all[i], tps, duration, tps_count)
    generateResourceConsumptionReportByTps(engines_all[i], tps, duration, tps_count)
  }
  generateResourceConsumptionReport(engines_all, tps, duration, tps_count)
  generateBenchmarkSpesificPercentile(engines_all, tps, duration, 99, tps_count)
  generateBenchmarkSpesificPercentile(engines_all, tps, duration, 95, tps_count)
  generateBenchmarkSpesificPercentile(engines_all, tps, duration, 90, tps_count)

} else {
  tps <- as.numeric(args[2])
  duration <- as.numeric(args[3])
  tps_count <- as.numeric(args[4])
  generateBenchmarkReport(args[1], tps, duration, tps_count)
  generateStreamServerLoadReport(args[1], tps, duration, tps_count)
  generateKafkaServerLoadReport(args[1], tps, duration, tps_count)
  generateBenchmarkPercentile(args[1], tps, duration, tps_count)
  generateResourceConsumptionReportByTps(args[1], tps, duration, tps_count)
}
  
generateResourceConsumptionReport(engines_all, tps, duration, tps_count)