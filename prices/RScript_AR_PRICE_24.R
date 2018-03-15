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
# script.dir <- dirname(sys.frame(1)$ofile)
script.dir <- 'C:/Users/NhatTan/Google Drive/Drobox backup/Papers/SoCC Prediction/prices'

path <- "/sigcomm09-energydb/data/"
file_name <- "price_0029.76_-095.36_tx.houston.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0037.34_-121.91_ca.np15.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0039.66_-082.01_pjm.ohio.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0039.94_-083.31_pjm.aep.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0040.54_-074.40_pjm.nj.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0040.75_-074.00_ny.nyc.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0041.85_-087.63_pjm.chi.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0042.36_-071.06_ne.bos.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));

# file_name <- "price_0033.97_-118.25_ca.sp15.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0034.92_-120.23_ca.zp26.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));

# file_name <- "price_0043.65_-070.26_ne.mn.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0043.23_-071.56_ne.nh.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0044.26_-072.57_ne.vt.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0042.65_-073.76_ny.capitl.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0044.54_-073.62_ny.north.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0040.75_-074.00_ny.nyc.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0040.52_-074.42_ny.pjm.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0042.89_-078.89_ny.west.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0039.94_-083.31_pjm.aep.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0037.56_-077.46_pjm.dom.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));

# file_name <- "price_0039.10_-075.62_pjm.east.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0041.77_-089.12_pjm.n_il.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));

# file_name <- "price_0039.66_-082.01_pjm.ohio.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0044.96_-093.16_miso.minn.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0039.23_-085.41_miso.cin.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0029.76_-095.36_tx.houston.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0033.10_-096.71_tx.north.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0029.66_-098.38_tx.south.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
# file_name <- "price_0032.02_-101.81_tx.west.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));

file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
rawValues = fileData[[2]]

# Averaging data
T_avg <- 1
dataLen <-  length(rawValues)
values  <-  matrix(rawValues, nrow = T_avg, byrow = FALSE)
values <-  colMeans(values)
day = 24;
# Prediction paramters
delay = 1;
embedded_dim= 7; # look back the past
futureSteps <- 30*delay # days of 24 hours
# trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 8 months.
# trainingDuration <- (31+28+31)*24 # 8 months.
# testDuration <- 7*24
trainingDuration <- 2*365*24 
testDuration <-  365*day 
# trainingDuration <- 2*30*day
# testDuration <-  7*day 
totalDuration <-  trainingDuration + testDuration

trainLen <-  trainingDuration/day
testLen <- testDuration/day
totalLen <- totalDuration/day

predictedValues = 0 * rawValues[seq(trainingDuration+1, totalDuration)]
expectedValues = rawValues[seq(trainingDuration+1, totalDuration)]

for (hr in seq(1,24)){
  rawValues_ts <-  ts(rawValues[seq(hr,totalDuration,day)], start=1, end = totalLen);
  x.test <- window(rawValues_ts, start = trainLen+1, end = totalLen)
  
  loopEnd = floor(testLen/futureSteps)
  if(loopEnd*futureSteps < testLen) {
    loopEnd = loopEnd + 1;
  }
  x.train <- window(rawValues_ts, start=1, end = trainLen);
  mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
  # mod.set <- arima(x.train, order=c(embedded_dim,0,0))
  
  for (i in seq(1,loopEnd) ) {
    startIdx <- (i-1)*futureSteps+1
    endIdx <- trainLen + (i-1)*futureSteps
    x.train <- window(rawValues_ts, start=startIdx, end=endIdx);
    ### Use different forecasting methods:
    if(IS_RETRAIN_MODEL) {
      mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
      # mod.set <- arima(x.train, order=c(embedded_dim,0,0))
    } else {
      mod.set$x = x.train;
    }
    nAhead <-  min(futureSteps, testDuration/day - (i-1)*futureSteps)
    # pred_linear_naive <- predict(mod.set, n.ahead=nAhead)
    pred_linear <- predict(mod.set, n.ahead=nAhead,  type="bootstrap", n.boot=200); pred_linear_naive = pred_linear$pred 
    startPredIdx <-  (i-1)*futureSteps+1
    endPredIdx   <-  startPredIdx + length(pred_linear_naive)-1;
    predictedValues[seq((startPredIdx-1)*day+hr, (endPredIdx-1)*day+hr, day)] = as.numeric(pred_linear_naive);
  }
}

predictedValues = abs(predictedValues);

predictedValues <- predictedValues + mean(expectedValues - predictedValues)

## Plot to compare results:
pred_range <- range(expectedValues, predictedValues, na.rm=TRUE)
plot(c(0,testDuration), pred_range)
lines(expectedValues, lty=1, col=1)
lines(predictedValues, lty=2, col=2)

legLabels <- c("real", "Predict")
legend("topleft", leg=legLabels, lty=1:5, col=1:5)

extraName = toString(futureSteps/delay);
dim = toString(embedded_dim);

errors <- expectedValues - predictedValues

cofficients <- mod.set$coefficients

folder <- "/errors/AR/"
## Save to files
if (IS_SAVE) {
  saveFile <- paste(script.dir,folder,file_name,"_24_","q_",dim,"_",extraName,".mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues, cofficients=cofficients,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
} else {
  saveFile <- paste(script.dir,folder,file_name,"_24_","q_",dim,"_",extraName,".t.mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues, cofficients= cofficients,
           matVersion="5", onWrite=NULL, verbose=FALSE)
}
mae = mean(abs(errors))
mae
avg_error = mean(errors)
avg_error
saveFile