rm(list=ls())
# Load packages & initialization
#install.packages("forecast")
#install.packages("R.matlab")
library(forecast)
library(R.matlab)
library(tsDyn)

IS_SAVE = TRUE

# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)
path <- "/data/"
file_name <- "price_37.34_-121.91_ca.np15.csv"

file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
powerMW = fileData[[2]]

# Averaging data
T_avg <- 1
dataLen <-  length(powerMW)
PowerMW_avg  <-  matrix(powerMW, nrow = T_avg, byrow = FALSE)
PowerMW_avg <-  colMeans(PowerMW_avg)
day = 24;
# Prediction paramters
delay = 24;
embedded_dim= 3; # look back the past
M = 7;
futureSteps <- 1 # days of 24 hours
trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 8 months.
testDuration <-  90*day #3*30*24
#trainingDuration <- (31+28)*24 # 8 months.
# testDuration <-  24 #3*30*24

PowerMW_avg_ts = ts(PowerMW_avg, start=1, end = trainingDuration+testDuration);
x.test <- window(PowerMW_avg_ts, start = trainingDuration+1, end = trainingDuration+testDuration)
predictedValues = numeric()
expectedValues = as.numeric(x.test)
loopEnd= floor(testDuration/futureSteps)

if(loopEnd*futureSteps < testDuration) {
  loopEnd = loopEnd + 1;
}

fixedVector = c(NA, rep(0,23), NA, rep(0,23), NA, rep(0,23-M), rep(NA,M), NA)
x.train <- window(PowerMW_avg_ts, start=1,end =trainingDuration);
mod.set <- arima(x.train, order=c((embedded_dim*delay),0,0), fixed = fixedVector, transform.pars = FALSE, method="CSS")

for (i in seq(1,loopEnd) ) {
  x.train <- window(PowerMW_avg_ts, start=i, end = trainingDuration + i-1);
  mod.set <- arima(x.train, order=c((embedded_dim*delay),0,0), fixed = fixedVector, transform.pars = FALSE, method="CSS")
  #x.extend = window(PowerMW_avg_ts, start=trainingDuration+(i-1)*futureSteps+1, end = trainingDuration +(i)*futureSteps);
  # x.extend = PowerMW_avg_ts[trainingDuration+i];
  # x.train <- append(x.train, x.extend)
  # mod.set$residuals = merge(mod.set$residuals,x.extend)
  # mod.set$residuals <- ets(x.train, model=mod.set$residuals)
  
  nAhead = min(futureSteps, testDuration - (i-1)*futureSteps)
  x.pred = forecast(mod.set, nAhead) 
  # as.numeric(x.pred$se)
  predictedValues = c(predictedValues, x.pred$mean);
}

## Plot to compare results:
# 
pred_range <- range(expectedValues, predictedValues, na.rm=TRUE)
plot(c(0,testDuration), pred_range)
lines(expectedValues, lty=1, col=1)
lines(predictedValues, lty=2, col=2)

legLabels <- c("real", "Predict")
legend("topleft", leg=legLabels, lty=1:5, col=1:5)

## Save to files
if (IS_SAVE) {
  extraName = toString(futureSteps/delay);
  errors <- predictedValues - expectedValues
  folder <- "/errors/AR_adv"
  saveFile <- paste(script.dir,folder,file_name,".mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
}