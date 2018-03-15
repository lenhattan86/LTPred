rm(list=ls())
# Load packages & initialization
#install.packages('TSA')
library(stats)
library(TSA)
library(R.matlab)
# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)
path <- "/data/"
save_path <- "/periodgram/price/"
file_name <- "price_37.34_-121.91_ca.np15.csv"
file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
prices = fileData[[2]]

# compute FFT and plot periodogram

periodogramData = periodogram(prices, plot=TRUE,ylab='prices')

value <- periodogramData$spec
freq <- periodogramData$freq

# Save results to files.
folder <- "/periodogram/"
saveFile <- paste(script.dir,folder,file_name,".mat", sep="")
writeMat(saveFile, value=value, freq=freq, matVersion="5", onWrite=NULL, verbose=FALSE)