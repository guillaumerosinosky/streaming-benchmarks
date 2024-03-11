
######################################################################################################################################
##########################                                                                                  ##########################
##########################                             Stream Benchmark Result                              ##########################
##########################                                                                                  ##########################
######################################################################################################################################
generateBenchmarkReport <- function(engine, tps, duration, tps_count, load_node_count){
  result <- NULL
  for(i in 1:tps_count) {
    TPS <- toString(tps * i)
    reportFolder <- paste0("/Users/sahverdiyev/IdeaProjects/dnysus/streaming-benchmarks/result/", engine, "/")
    sourceFolder <- paste0("/Users/sahverdiyev/IdeaProjects/dnysus/streaming-benchmarks/result/", engine, "/TPS_", TPS, "_DURATION_", toString(duration), "/")
    Seen <- read.table(paste0(sourceFolder, "redis-seen.txt"), header=F, stringsAsFactors=F, sep=',')
    Updated <- read.table(paste0(sourceFolder, "redis-updated.txt"), header=F, stringsAsFactors=F, sep=',')

    SeenFiltered <- NULL
    UpdatedFiltered <- NULL
    for(c in 1:(length(Updated$V1)-1)) {
      if(Seen$V1[c] != Seen$V1[c+1] && Updated$V1[c] != Updated$V1[c+1] && Updated$V1[c] > 10000){
        SeenFiltered <- c(SeenFiltered, Seen$V1[c])
        UpdatedFiltered <- c(UpdatedFiltered, Updated$V1[c])
      }
    }
    windows <- seq_along(UpdatedFiltered)
    
    df <- data.frame(toString(tps*i*load_node_count), SeenFiltered, UpdatedFiltered - 10000, windows)
    result <- rbind(result, df)
    
    if (length(Seen$V1)  != length(Updated$V1)){ 
      stop("Input data set is wrong. Be sure you have selected correct collections")
    }

    names(df) <- c("TPS","Seen","Throughput", "Percentile")
    ggplot(data=df, aes(x=Percentile, y=Throughput, group=TPS, colour=TPS)) + 
      geom_smooth(method="loess", se=F, size=0.5) + 
      guides(fill=FALSE) +
      scale_y_continuous(breaks= pretty_breaks()) +
      xlab("Windows") + ylab("Latency (ms)") +
      #ggtitle(paste(toupper(engine), "Benchmark", sep = " ")) +
      theme(plot.title = element_text(size = 8, face = "plain"), 
            text = element_text(size = 7, face = "plain"),
            legend.justification = c(0, 1), 
            legend.position = c(0, 1),
            legend.box.margin=margin(c(3,3,3,3)),
            legend.key.height=unit(0.5,"line"),
            legend.key.width=unit(0.5,"line"),
            legend.text=element_text(size=rel(0.7)))
    ggsave(paste0(engine, "_", toString(tps * i * load_node_count), ".pdf"), width = 8, height = 8, units = "cm", device = "pdf", path = sourceFolder)
  }
  names(result) <- c("TPS","Seen","Throughput", "Percentile")
  result <- result[result$Throughput > 0,]
  ggplot(data=result, aes(x=Percentile, y=Throughput, group=TPS, colour=TPS)) + 
    geom_smooth(method="loess", se=F, size=0.5) + 
    guides(fill=FALSE) +
    scale_y_continuous(breaks= pretty_breaks()) +
    xlab("Windows") + ylab("Latency (ms) ") +
    #ggtitle(paste(toupper(engine), ", Loess regression of latencies", sep = " ")) +
    theme(plot.title = element_text(size = 8, face = "plain"), 
          text = element_text(size = 7, face = "plain"),
          legend.justification = c(0, 1), 
          legend.position = c(0, 1),
          legend.key.height=unit(0.5,"line"),
          legend.key.width=unit(0.5,"line"),
          legend.box.margin=margin(c(3,3,3,3)),
          legend.text=element_text(size=rel(0.7)))
  ggsave(paste0(engine, "_", duration, ".pdf"), width = 8, height = 8, units = "cm", device = "pdf", path = reportFolder)
}
