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
script.dir <- 'C:/Users/NhatTan/Dropbox/Papers/SoCC Prediction/prices'

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

# localTime = as.Date(localTime)
# df1 = data.frame(localTime, rawValues)
# names(df1) <- c('dates','values')
# df1$Month <- months(df1$dates)
# df1$Year <- format(df1$dates,format="%y")
# avgMonthValues = aggregate(values ~ Month + Year , df1 , mean)

# Averaging data
T_avg <- 1
dataLen <-  length(rawValues)
values  <-  matrix(rawValues, nrow = T_avg, byrow = FALSE)
values <-  colMeans(values)
day = 24;
# Prediction paramters
delay = 1;
embedded_dim= 2; # look back the past
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
  rawDates_ts <- localTime[seq(hr,totalLen*day,day)]
  
  rawDates_ts = as.Date(rawDates_ts)
  df1 = data.frame(rawDates_ts, rawValues_ts)
  names(df1) <- c('dates','values')
  df1$Month <- months(df1$dates)
  df1$Year <- format(df1$dates,format="%y")
  avgMonthValues = aggregate(values ~ Month + Year , df1 , mean)
  for (i in seq()){
    monthAvg[i] = 
  }
  
  x.train <- window(rawValues_ts, start=1, end = trainLen);
  xAvg.train <- window(df1$monthAvg, start=1, end = trainLen);
  
  x.test <- window(rawValues_ts, start = trainLen+1, end = totalLen)
  xAvg.test <- window(df1$monthAvg, start = trainLen+1, end = totalLen)
  
  
  #  Aggregate 'X2' on months and year and get mean
 
  
  # for i in seq(1,embedded_dim):
    x1 = window(x.train,  start=1, end = trainLen-futureSteps-embedded_dim+1);
    x2 = window(x.train,  start=2, end = trainLen-futureSteps-embedded_dim+2);
  # ends
    xhat1 = window(x.train,  start=1, end = trainLen-futureSteps-embedded_dim+1);
  
  # train the model for every hour  
  input <- data.frame(x1,x2);
  names(input) <- c('x1','x2')
  
  model <- lm(mpg~disp+hp+wt, data = input)
  
  # mod.set <- arima(x.train, order=c(embedded_dim,0,0))
  
  # predicted values
}

#predictedValues = abs(predictedValues);

#predictedValues <- predictedValues + mean(expectedValues - predictedValues)

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

folder <- "/errors/LM/"
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