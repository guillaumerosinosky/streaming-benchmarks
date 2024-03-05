#!/usr/bin/env Rscript
require(devtools)
# install_version("ggplot2", version = "2.2.1", repos = "http://cran.us.r-project.org")
# install_version("dplyr", version = "0.7.4", repos = "http://cran.us.r-project.org")
# install_version("scales", version = "0.4.1", repos = "http://cran.us.r-project.org")
library(ggplot2)
library(scales)
library(dplyr)
library(grid)

theme_set(theme_bw())
options("scipen"=10)
args <- commandArgs(TRUE)
tps <- as.numeric(args[2])
duration <- as.numeric(args[3])
tps_count <- as.numeric(args[4])
engines_all <- c("flink","spark", "kafka")
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/util.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/StreamServerReport.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/KafkaServerReport.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/BenchmarkResult.r')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/BenchmarkPercentile.R')
source('~/IdeaProjects/dnysus/streaming-benchmarks/reporting/ResourceConsumptionReport.r')
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

generateBenchmarkReport(args[1], tps, duration, tps_count)
generateStreamServerLoadReport(args[1], tps, duration, tps_count)
generateKafkaServerLoadReport(args[1], tps, duration, tps_count)
generateBenchmarkPercentile(args[1], tps, duration, tps_count)


tps_count = 15
#generateBenchmarkPercentile("kafka", 1000, 600, 15)

if(length(args) == 0){
  for (i in 1:length(engines_all)) { 
    generateBenchmarkReport(engines_all[i], 1000, 600, tps_count)
    # generateStreamServerLoadReport(engines_all[i], 1000, 600, tps_count)
    # generateKafkaServerLoadReport(engines_all[i], 1000, 600, tps_count)
    generateBenchmarkPercentile(engines_all[i], 1000, 600, tps_count)
    # generateResourceConsumptionReportByTps(engines_all[i], 1000, 600, tps_count)
  }
  # generateResourceConsumptionReport(engines_all, 1000, 600, tps_count)
  generateBenchmarkSpesificPercentile(engines_all, 1000, 600, 99, tps_count)
  generateBenchmarkSpesificPercentile(engines_all, 1000, 600, 95, tps_count)
  generateBenchmarkSpesificPercentile(engines_all, 1000, 600, 90, tps_count)
  
}
  
# generateResourceConsumptionReport(engines_all, 1000, 600, 15)