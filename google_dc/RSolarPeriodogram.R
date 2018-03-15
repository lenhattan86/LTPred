rm(list=ls())
# Load packages & initialization
#install.packages('TSA')
library(stats)
library(TSA)
library(R.matlab)
# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)

# path <- "/NREL_SAM/SOLAR/"
# save_path <- "/periodogram/SOLAR/"
# file_name <- "AL_34.65_-86.783.csv"

# path <- "/NREL_SAM/SOLAR/"
# save_path <- "/periodogram/SOLAR/"
# file_name <- "AL_34.65_-86.783.csv"

# path <- "/NREL_SAM/WIND/"
# save_path <- "/periodogram/WIND/"
# file_name <- "AL_34.65_-86.783.csv"

# path <- "/NREL_SAM/SOLAR/"
# save_path <- "/periodogram/SOLAR/"
# file_name <- "AL_34.65_-86.783_2007_2009.csv"

path <- "/NREL_SAM/WIND/"
save_path <- "/periodogram/WIND/"
file_name <- "AL_34.65_-86.783_merge.csv"



file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
powerMW = fileData[[2]]
# Averaging data
T_avg <- 1
dataLen <-  length(powerMW)
PowerMW_avg  <-  matrix(powerMW, nrow = T_avg, byrow = FALSE)
PowerMW_avg <-  colMeans(PowerMW_avg)

# compute FFT and plot periodogram
# periodogram = fft(PowerMW_avg, inverse = FALSE)
# plot(periodogram)

#plot(PowerMW_avg,xlab='Day',ylab='Brightness')
periodogramData = periodogram(PowerMW_avg, plot=TRUE, ylab='Power')

value <- periodogramData$spec
freq <- periodogramData$freq

# Save results to files.
saveFile <- paste(script.dir,save_path,file_name,".mat", sep="")
writeMat(saveFile, value=value, freq=freq, matVersion="5", onWrite=NULL, verbose=FALSE)
saveFile