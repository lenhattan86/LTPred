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
path <- "/NREL_SAM/WIND/"

# file_name <- "LA_31.17_-91.87_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 15));
# file_name <- "ME_44.69_-69.38_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 15));
# file_name <- "MI_43.33_-84.54_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 15));
# file_name <- "MO_38.46_-92.29_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 15));
file_name <- "WY_42.76_-107.3_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 15));

# many years
# file_name <- "AL_34.65_-86.783_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 16));
# file_name <- "GA_33.65_-84.433_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 16));
# file_name <- "IA_41.017_-94.367_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NC_35.733_-81.383_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 16));
# file_name <- "OK_36.2_-95.883_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 7)); Lon <- as.numeric(substr(file_name, 9, 15));
 # file_name <- "OR_45.55_-122.4_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 14));
# file_name <- "SC_33.967_-80.467_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));

# file_name <- "CA_037.00_-120.00_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "FL_027.77_-081.69_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "ND_047.53_-099.78_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NE_041.13_-098.27_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NY_042.17_-074.95_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "TX_031.05_-097.56_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
file_name <- "WA_047.40_-121.49_merge.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));

file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
powerMW   = fileData[[3]]


# Averaging data
T_avg <- 1
dataLen <-  length(powerMW)
PowerMW_avg  <-  matrix(powerMW, nrow = T_avg, byrow = FALSE)
PowerMW_avg <-  colMeans(PowerMW_avg)
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
totalDuration <-  trainingDuration + testDuration

trainLen <-  trainingDuration/day
testLen <- testDuration/day
totalLen <- totalDuration/day


predictedValues = 0 * PowerMW_avg[seq(trainingDuration+1, totalDuration)]
expectedValues = PowerMW_avg[seq(trainingDuration+1, totalDuration)]

for (hr in seq(1,24)){
  PowerMW_avg_ts <-  ts(PowerMW_avg[seq(hr,totalDuration,day)], start=1, end = totalLen);
  x.test <- window(PowerMW_avg_ts, start = trainLen+1, end = totalLen)
  
  loopEnd = floor(testLen/futureSteps)
  if(loopEnd*futureSteps < testLen) {
    loopEnd = loopEnd + 1;
  }
  x.train <- window(PowerMW_avg_ts, start=1, end = trainLen);
  mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
  # mod.set <- arima(x.train, order=c(embedded_dim,0,0))
  
  for (i in seq(1,loopEnd) ) {
    startIdx <- (i-1)*futureSteps+1
    endIdx <- trainLen + (i-1)*futureSteps
    x.train <- window(PowerMW_avg_ts, start=startIdx, end=endIdx);
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

errors = expectedValues - predictedValues

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

## Save to files
extraName = toString(futureSteps/delay);
dim = toString(embedded_dim);

cofficients <- mod.set$coefficients

folder <- "/errors/AR/WIND/"
if (IS_SAVE) {
  saveFile <- paste(script.dir,folder,file_name,"_24_","q_",dim,"_",extraName, ".mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat, errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues, predictedValues=predictedValues, cofficients=cofficients,
           matVersion="5", onWrite=NULL, verbose=FALSE)
} else {
  saveFile <- paste(script.dir,folder,file_name,"_24_","q_",dim,"_",extraName,".t.mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues, cofficients=cofficients,
           matVersion="5", onWrite=NULL, verbose=FALSE)
}

mae = mean(abs(errors))
mae
avg_error = mean(predictedValues - expectedValues)
avg_error
saveFile