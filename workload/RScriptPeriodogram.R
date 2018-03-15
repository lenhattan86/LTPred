rm(list=ls())
# Load packages & initialization
#install.packages('TSA')
library(stats)
library(TSA)
library(R.matlab)
# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)

path <- "/Akamai/"
save_path <- "/errors/"
file_name <- "AL_0034.77_-086.68_workload.csv"



file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
values = fileData[[2]]
dataLen = length(values);

# Averaging data
T_avg <- 12
values_avg  <-  matrix(values, nrow = T_avg, byrow = FALSE)
values_avg <-  colMeans(values_avg)

# compute FFT and plot periodogram
# periodogram = fft(values_avg, inverse = FALSE)
# plot(periodogram)

#plot(values_avg,xlab='Day',ylab='Brightness')
periodogramData = periodogram(values_avg, plot=TRUE, ylab='Power')

value <- periodogramData$spec
freq <- periodogramData$freq

# Save results to files.
saveFile <- paste(script.dir,save_path,file_name,".mat", sep="")
writeMat(saveFile, value=value, freq=freq, matVersion="5", onWrite=NULL, verbose=FALSE)
saveFile