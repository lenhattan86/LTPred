rm(list=ls())
# Load packages & initialization
#install.packages("forecast")
#install.packages("R.matlab")
#library(forecast)
library(R.matlab)
library(tsDyn)

IS_SAVE = TRUE
# IS_SAVE = FALSE
IS_RETRAIN_MODEL = TRUE
# IS_RETRAIN_MODEL = FALSE

# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)

path <- "/sigcomm09-energydb/data/"
file_name <- "price_0029.76_-095.36_tx.houston.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0037.34_-121.91_ca.np15.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0039.66_-082.01_pjm.ohio.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0039.94_-083.31_pjm.aep.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0040.54_-074.40_pjm.nj.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0040.75_-074.00_ny.nyc.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0041.85_-087.63_pjm.chi.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0042.36_-071.06_ne.bos.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));

file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
rawValues = fileData[[2]]

# Averaging data
T_avg <- 1
dataLen <-  length(rawValues)
rawValues_avg  <-  matrix(rawValues, nrow = T_avg, byrow = FALSE)
rawValues_avg <-  colMeans(rawValues_avg)
day = 24;
# Prediction paramters
delay = 24;
embedded_dim= 60; # look back the past
futureSteps <- 10*day # days of 24 hours
# trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 8 months.
# testDuration <- 3*30*24
trainingDuration <- 2*365*24 # 8 months.
testDuration <-  365*day 

values = ts(rawValues_avg, start=1, end = trainingDuration+testDuration);
x.test <- window(values, start = trainingDuration+1, end = trainingDuration+testDuration)
predictedValues = numeric()
expectedValues = as.numeric(x.test)
loopEnd = floor(testDuration/futureSteps)

if(loopEnd*futureSteps < testDuration) {
  loopEnd = loopEnd + 1;
}

x.train <- window(values, start=1, end = trainingDuration);
mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)

for (i in seq(1,loopEnd) ) {
  x.train <- window(values, start=(i-1)*futureSteps+1, end = trainingDuration + (i-1)*futureSteps);
  ### Use different forecasting methods:
  if(IS_RETRAIN_MODEL) {
    mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
    #mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps, type="diff")
    #mod.set <- nnetTs(x.train, m=embedded_dim, d=delay, steps=futureSteps, size = 3)
  } else {
    mod.set$x = x.train;
  }
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
pred_range <- range(expectedValues, predictedValues, na.rm=TRUE)
plot(c(0,testDuration), pred_range)
lines(expectedValues, lty=1, col=1)
lines(predictedValues, lty=2, col=2)
#lines(pred_setar_boot$pred, lty=3, col=3)
#lines(pred_setar_Bboot$pred, lty=4, col=4)
#lines(pred_setar_MC$pred, lty=5, col=5)
#legLabels <- c("Observed", "Naive F", "Bootstrap F","Block-Bootstrap F", "MC F")
legLabels <- c("real", "Predict")
legend("topleft", leg=legLabels, lty=1:5, col=1:5)

extraName = toString(futureSteps/delay);
errors <- expectedValues - predictedValues
folder <- "/errors/AR/"
## Save to files
if (IS_SAVE) {
  saveFile <- paste(script.dir,folder,file_name,"_",extraName,".mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
} else {
  saveFile <- paste(script.dir,folder,file_name,"_",extraName,".t.mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
}
mae = mean(abs(errors))
mae
avg_error = mean(errors)
avg_error
saveFile