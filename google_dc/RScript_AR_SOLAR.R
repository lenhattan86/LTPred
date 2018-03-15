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
#path <- "/PV/AL_PV_2006/"
#file_name <- "Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv"
path <- "/NREL_SAM/SOLAR/"
# file_name <- "AL_34.65_-86.783.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 16));
# file_name <- "GA_33.65_-84.433.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 16));
# file_name <- "IA_41.017_-94.367.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NC_35.733_-81.383.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 16));
# file_name <- "OK_36.2_-95.883.csv"; Lat <- as.numeric(substr(file_name, 4, 7)); Lon <- as.numeric(substr(file_name, 9, 15));
# file_name <- "OR_45.55_-122.4.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 14));
# file_name <- "SC_33.967_-80.467.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));

# many years
file_name <- "AL_34.65_-86.783_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 16));
# file_name <- "GA_33.65_-84.433_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 16));
# file_name <- "IA_41.017_-94.367_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NC_35.733_-81.383_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 16));
# file_name <- "OK_36.2_-95.883_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 7)); Lon <- as.numeric(substr(file_name, 9, 15));
# file_name <- "OR_45.55_-122.4_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 8)); Lon <- as.numeric(substr(file_name, 10, 14));
# file_name <- "SC_33.967_-80.467_2007_2009.csv"; Lat <- as.numeric(substr(file_name, 4, 9)); Lon <- as.numeric(substr(file_name, 11, 17));

file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
powerMW = fileData[[11]]

# Averaging data
T_avg <- 1
dataLen <-  length(powerMW)
PowerMW_avg  <-  matrix(powerMW, nrow = T_avg, byrow = FALSE)
PowerMW_avg <-  colMeans(PowerMW_avg)
day = 24;
# Prediction paramters
delay = 24;
embedded_dim= 60; # look back the past
futureSteps <- 30*day # days of 24 hours
# trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 8 months.
# testDuration <- 3*30*24
trainingDuration <- 2*365*24
testDuration <-  365*day 

PowerMW_avg_ts = ts(PowerMW_avg, start=1, end = trainingDuration+testDuration);
x.test <- window(PowerMW_avg_ts, start = trainingDuration+1, end = trainingDuration+testDuration)
predictedValues = numeric()
expectedValues = as.numeric(x.test)
loopEnd = floor(testDuration/futureSteps)

if(loopEnd*futureSteps < testDuration) {
  loopEnd = loopEnd + 1;
}

x.train <- window(PowerMW_avg_ts, start=1, end = trainingDuration);
mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)

for (i in seq(1,loopEnd) ) {
  x.train <- window(PowerMW_avg_ts, start=(i-1)*futureSteps+1, end = trainingDuration + (i-1)*futureSteps);
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
folder <- "/errors/AR/SOLAR/"
## Save to files
if (IS_SAVE) {
  saveFile <- paste(script.dir,folder,file_name,"_",extraName,".mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
} else {
  saveFile <- paste(script.dir,folder,file_name,"_",extraName,".t.mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
}
mae = mean(abs(errors))
mae
avg_error = mean(errors)
avg_error
saveFile