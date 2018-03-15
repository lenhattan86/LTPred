rm(list=ls())
# Load packages & initialization
#install.packages("forecast")
#install.packages("R.matlab")
#library(forecast)
library(R.matlab)
library(tsDyn)

# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)
path <- "/data/"
file_name <- "price_37.34_-121.91_ca.np15.csv"
file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
prices = fileData[[2]]

IS_SAVE = FALSE

# Averaging data
dataLen <-  length(prices)

day = 24;
# Prediction paramters
delay = 12;
embedded_dim= 60; # look back the past
futureSteps <- 1*delay # days of 24 hours
#trainingDuration <- (31+28+31+30+31+30+31+31+30+30)*24 # 9 months.
trainingDuration <- 365*day # 9 months.
testDuration <-  7*day #3*30*24

prices_ts = ts(prices, start=1, end = trainingDuration+testDuration);
x.test <- window(prices_ts, start = trainingDuration+1, end = trainingDuration+testDuration)
predictedValues = numeric()
expectedValues = as.numeric(x.test)
loopEnd= floor(testDuration/futureSteps)

if(loopEnd*futureSteps < testDuration) {
  loopEnd = loopEnd + 1;
}
  
for (i in seq(1,loopEnd) ) {
  x.train <- window(prices_ts, start=(i-1)*futureSteps+1, end = trainingDuration + (i-1)*futureSteps);
  ### Use different forecasting methods:
  #mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
  mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
  # mod.set <- nnetTs(x.train, m=embedded_dim, d=delay, steps=futureSteps,size = 1)
  # mod.set <- setar(x.train, m=embedded_dim, thDelay=0)
  # mod.set <- lstar(x.train, m=embedded_dim, d=delay, steps=futureSteps)
  # mod.set <- star(x.train, m=embedded_dim, d=delay, steps=futureSteps,size = 1)
  # mod.set <- aar(x.train, m=, type="diff", d=delay, steps=futureSteps)
  
  #pred_linear_naive <- predict(mod.set, n.ahead=futureSteps)
  nAhead = min(futureSteps, testDuration - (i-1)*futureSteps)
  pred_linear_naive <- predict(mod.set, n.ahead=nAhead)
  predictedValues = c(predictedValues, as.numeric(pred_linear_naive));
  #pred_setar_boot <- predict(mod.set, n.ahead=testDuration, type="bootstrap", n.boot=200)
  #pred_setar_Bboot <- predict(mod.set, n.ahead=testDuration, type="block-bootstrap", n.boot=200)
  #pred_setar_MC <- predict(mod.set, n.ahead=testDuration, type="bootstrap", n.boot=200)
}

## Plot to compare results:
#pred_range <- range(pred_linear_naive, pred_setar_boot$pred, pred_setar_MC$pred, na.rm=TRUE)
pred_range <- range(expectedValues,predictedValues, na.rm=TRUE)
plot(c(0,testDuration), pred_range)
lines(expectedValues, lty=1, col=1)
lines(predictedValues, lty=2, col=2)
#lines(pred_setar_boot$pred, lty=3, col=3)
#lines(pred_setar_Bboot$pred, lty=4, col=4)
#lines(pred_setar_MC$pred, lty=5, col=5)
#legLabels <- c("Observed", "Naive F", "Bootstrap F","Block-Bootstrap F", "MC F")
legLabels <- c("real", "Predict")
legend("topleft", leg=legLabels, lty=1:5, col=1:5)

## Save to files
if (IS_SAVE) {
  errors <- predictedValues - expectedValues
  Lon <- as.numeric(substr(file_name, 8, 12))
  Lat <- as.numeric(substr(file_name, 14, 19))
  folder <- "/errors/AR/"
  saveFile <- paste(script.dir,folder,file_name,".mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
}