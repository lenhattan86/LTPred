rm(list=ls())
# Load packages & initialization
#install.packages("forecast")
#install.packages("R.matlab")
library(forecast)
library(R.matlab)

# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)
path <- "/PV/AL_PV_2006/"
file_name <- "Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv"
file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
powerMW = fileData[[2]]
# Averaging data
T_avg <- 12
dataLen <-  length(powerMW)
PowerMW_avg  <-  matrix(powerMW, nrow = T_avg, byrow = FALSE)
PowerMW_avg <-  colMeans(PowerMW_avg)
# Prediction paramters
pastSteps <- 60 #30*24 # days of 24 hours

futureSteps <- 30 # days of 24 hours
futureDuration <- 30*24;
#futureSteps <- 24
trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 9 months.
#trainingDuration <- (30)*24 # 
testDuration <- 3*30*24 

# ARIMA paramenters
p <- pastSteps # aggressive 
d <- 0 # differences
q <- 0 #moving average

# Training
period = 24;
startAt = 14;
sensor<-ts(PowerMW_avg[seq(startAt, trainingDuration, period)],frequency=1)#daily data of month,here only 2 month's data
#fit <- auto.arima(sensor,D=1)
fit <- arima(sensor, order=c(p,d,q))
# Predict K ahead
LH.pred <- forecast.Arima(fit,h=futureSteps)
plot(LH.pred)
grid()

predictedValues <-  c(LH.pred$mean)
upperboundValues <- c(LH.pred$upper)
lowerboundValues <- c(LH.pred$lower)
expectedValues <-  PowerMW_avg[seq(trainingDuration+startAt, trainingDuration+futureDuration, period)]
errors <- predictedValues - expectedValues

# Save results to files.
#'Lon','Lat','errors', 'expectedValues', 'predictedValues'
Lon <- as.numeric(substr(file_name, 8, 12))
Lat <- as.numeric(substr(file_name, 14, 19))
folder <- "/errors/"
saveFile <- paste(script.dir,folder,file_name,".mat", sep="")
writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors,
         expectedValues=expectedValues,predictedValues=predictedValues,
         upperboundValues=upperboundValues, lowerboundValues=lowerboundValues
         , matVersion="5", onWrite=NULL, verbose=FALSE)