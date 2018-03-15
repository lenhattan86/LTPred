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

path <- "/Akamai/"
# file_name <- "AL_0034.77_-086.68_owrkload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "GA_0033.72_-084.47_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "IA_0041.58_-093.68_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "NC_0035.99_-078.90_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "SC_0034.07_-081.19_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "OK_0035.48_-097.50_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "OR_0044.81_-122.68_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "SC_0034.07_-081.19_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));

# file_name <- "VA_0038.02_-078.57_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "TN_0036.07_-086.72_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "AR_0034.57_-092.64_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "MA_0042.35_-071.55_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));

# file_name <- "CA_0037.28_-120.45_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
##### file_name <- "FL_0027.93_-082.37_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "ND_0046.97_-097.99_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "NE_0040.80_-096.67_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
file_name <- "NY_0041.59_-075.54_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "TX_0031.11_-097.73_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "LA_0030.53_-091.12_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "ME_0044.85_-068.83_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
### file_name <- "MI_0043.58_-084.35_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "MO_0038.90_-092.24_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));

# file_name <- "WY_0043.10_-108.94_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));
# file_name <- "WA_0047.57_-121.78_workload.csv"; Lat <- as.numeric(substr(file_name, 4, 10)); Lon <- as.numeric(substr(file_name, 12,18));

file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
rawValues = fileData[[2]]

# Averaging data
T_avg <- 12
dataLen <-  length(rawValues)
values  <-  matrix(rawValues, nrow = T_avg, byrow = FALSE)
values <-  colMeans(values)
day = 24;
# Prediction paramters
delay = 1;
embedded_dim= 7; # look back the past
futureSteps <- 1*delay # days of 24 hours
# trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 8 months.
# trainingDuration <- (31+28+31)*24 # 8 months.
# testDuration <- 7*24
trainingDuration <- 45*day 
testDuration <-  15*day 
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
    pred_linear_naive <- predict(mod.set, n.ahead=nAhead)
    # pred_linear_MC <- predict(mod.set, n.ahead=nAhead, type="MC"); pred_linear_naive <-  pred_linear_MC$pred;
    startPredIdx <-  (i-1)*futureSteps+1
    endPredIdx   <-  startPredIdx + length(pred_linear_naive)-1;
    predictedValues[seq((startPredIdx-1)*day+hr, (endPredIdx-1)*day+hr, day)] = as.numeric(pred_linear_naive);
  }
}

predictedValues = abs(predictedValues);

## Plot to compare results:
pred_range <- range(expectedValues, predictedValues, na.rm=TRUE)
plot(c(0,testDuration), pred_range)
lines(expectedValues, lty=1, col=1)
lines(predictedValues, lty=2, col=2)

legLabels <- c("real", "Predict")
legend("topleft", leg=legLabels, lty=1:5, col=1:5)

extraName = toString(futureSteps/delay);
dim = toString(embedded_dim);
errors <- expectedValues- predictedValues
folder <- "/errors/AR/"
## Save to files
if (IS_SAVE) {
  saveFile <- paste(script.dir,folder,file_name,"_24_","q_",dim,"_",extraName,".mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
} else {
  saveFile <- paste(script.dir,folder,file_name,"_24_","q_",dim,"_",extraName,".t.mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
}
mae = mean(abs(errors))
mae
avg_error = mean(errors)
avg_error
saveFile