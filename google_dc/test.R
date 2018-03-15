rm(list=ls())
# Load packages & initialization
#install.packages("forecast")
#install.packages("R.matlab")
#library(forecast)
library(R.matlab)
library(tsDyn)

IS_SAVE = TRUE

# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)
location <- c("AL","GA","NC","OK","OR","SC","IA")
year <- c(2005, 2006, 2007, 2008, 2009, 2010)
file_coordinate <- "Solar_34.65_-86.783_AL_2005_temp.csv"
file_last <- "_temp.csv"
for (val in location) {
path <- paste("/data_solar_energy/",val,"/", sep = "", collapse = NULL)
if (val == "AL") 
  file_coordinate <- "Solar_34.65_-86.783_AL_"
 else if(val == "GA") 
  file_coordinate <- "Solar_33.767_-84.517_GA_"
 else if(val == "NC") 
  file_coordinate <- "Solar_35.733_-81.383_NC_"
 else if(val == "OK") 
  file_coordinate <- "Solar_36.2_-95.883_OK_"
 else if(val == "OR") 
  file_coordinate <- "Solar_45.617_-121.15_OR_"
 else if(val == "SC") 
  file_coordinate <- "Solar_32.9_-80.033_SC_"
 else if(val == "IA")
  file_coordinate <- "Solar_41.267_-95.767_IA_"

for(val in year) {
file_name <- paste(file_coordinate,val,file_last, sep = "", collapse = NULL)
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
embedded_dim= 14; # look back the past
futureSteps <- 10*day # days of 24 hours
#trainingDuration <- (31+28+31+30+31+30+31+31+30+30)*24 # 9 months.
trainingDuration <- 6*30*day # 9 months.
testDuration <-  7*day #3*30*24

PowerMW_avg_ts = ts(PowerMW_avg, start=1, end = trainingDuration+testDuration);
x.test <- window(PowerMW_avg_ts, start = trainingDuration+1, end = trainingDuration+testDuration)
predictedValues = numeric()
expectedValues = as.numeric(x.test)
loopEnd= floor(testDuration/futureSteps)

if(loopEnd*futureSteps < testDuration) {
  loopEnd = loopEnd + 1;
}

for (i in seq(1,loopEnd) ) {
  x.train <- window(PowerMW_avg_ts, start=(i-1)*futureSteps+1, end = trainingDuration + (i-1)*futureSteps);
  ### Use different forecasting methods:
  mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps)
  #mod.set <- linear(x.train, m=embedded_dim, d=delay, steps=futureSteps, type="diff")
  #mod.set <- nnetTs(x.train, m=embedded_dim, d=delay, steps=futureSteps,size = 3)
  
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
  extraName = toString(futureSteps/delay);
  errors <- predictedValues - expectedValues
  Lon <- as.numeric(substr(file_name, 8, 12))
  Lat <- as.numeric(substr(file_name, 14, 19))
  folder <- "/errors/AR/"
  saveFile <- paste(script.dir,folder,file_name,"_",extraName,".mat", sep="")
  writeMat(saveFile, Lon=Lon,Lat=Lat ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
}
}
}