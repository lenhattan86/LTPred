# reset all & load libraries
# refer http://www.r-bloggers.com/fitting-a-neural-network-in-r-neuralnet-package/
rm(list=ls())
# install.packages('neuralnet')
# install.packages('R.matlab')
# install.packages('lubridate')
library("neuralnet")
library(R.matlab)
library(chron)
library(timeDate)
library(lubridate)


# common parameter
IS_SAVE = TRUE
# IS_SAVE = FALSE


### load data 
#script.dir <- dirname(sys.frame(1)$ofile)
# script.dir <- "C:/Users/lenha/Dropbox/Papers/SoCC Prediction/prices";
script.dir <- 'C:/Users/NhatTan/Dropbox/Papers/SoCC Prediction/prices'
# price
path <- "/sigcomm09-energydb/data/"
# file_name <- "price_0029.76_-095.36_tx.houston.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
file_name <- "price_0037.34_-121.91_ca.np15.csv"; Lat <- as.numeric(substr(file_name, 7, 13)); Lon <- as.numeric(substr(file_name, 15,21));
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
fileData  = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]

normFunc <- function(m){(m-min(m))/(max(m)-min(m))}


values   = as.numeric(fileData[[2]])
valMax = max(values);
valMin = min(values);

monthOfYears = as.numeric(substring(localTime, first = 6, last = 7))
dayOfMonths  = as.numeric(substring(localTime, first = 9, last = 10))
hourOfDays   = as.numeric(substring(localTime, first = 12, last = 13))
dayOfWeeks   = wday(as.Date(substring(localTime, first = 1, last = 10),'%Y-%m-%d'))

normValues = normFunc(values)
normMonthOfYears = normFunc(monthOfYears)
normDayOfMonths= normFunc(dayOfMonths)
normHourOfDays = normFunc(hourOfDays)
normdayOfWeeks = normFunc(dayOfWeeks)

day = 24; 
historicalRange = 2*day;
futureSteps = 30*day; # days;
trainingDuration <- 90*day 
testDuration <-  7*day 
### prepare data for training
trainHistoricalValues1           = normValues[seq(1, trainingDuration)]
trainHistoricalValues2           = normValues[seq(day+1, trainingDuration+day+1)]
valuesTrain          = normValues[seq(historicalRange+1+futureSteps, historicalRange+trainingDuration+futureSteps)]

monthOfYearsTrain    = normMonthOfYears[seq(historicalRange+1+futureSteps, historicalRange+trainingDuration+futureSteps)]
dayOfMonthsTrain     = normDayOfMonths[seq(historicalRange+1+futureSteps, historicalRange+trainingDuration+futureSteps)]
hourOfDaysTrain      = normHourOfDays[seq(historicalRange+1+futureSteps, historicalRange+trainingDuration+futureSteps)]
dayOfWeeksTrain      = normdayOfWeeks[seq(historicalRange+1+futureSteps, historicalRange+trainingDuration+futureSteps)]

### prepare data for forecasting

totalDuration <-  historicalRange+trainingDuration + testDuration + futureSteps
testHistoricalValues1  = normValues[seq(historicalRange+trainingDuration+1, totalDuration-futureSteps)]
testHistoricalValues2  = normValues[seq(historicalRange+trainingDuration+day+1, totalDuration-futureSteps+day)]

monthOfYearsTest = normMonthOfYears[seq(historicalRange+trainingDuration+futureSteps+1, totalDuration)]
dayOfMonthsTest  = normDayOfMonths[seq(historicalRange+trainingDuration+futureSteps+1, totalDuration)]
hourOfDaysTest   = normHourOfDays[seq(historicalRange+trainingDuration+futureSteps+1, totalDuration)]
dayOfWeeksTest   = normdayOfWeeks[seq(historicalRange+trainingDuration+futureSteps+1, totalDuration)]

### train

trainingdata <- cbind(monthOfYearsTrain,dayOfMonthsTrain,hourOfDaysTrain,dayOfWeeksTrain, trainHistoricalValues1, trainHistoricalValues2, valuesTrain)
colnames(trainingdata) <- c("month","day","hour","dayOfWeek","historicalValues1","historicalValues2","valuesTrain")
net.model <- neuralnet(valuesTrain~month+day+hour+dayOfWeek+historicalValues1+historicalValues2,trainingdata, hidden=10, 
                       act.fct="tanh", threshold=0.05*mean(normValues),stepmax=1e6)

### forecast
# plot(net.model)
testdata=cbind(monthOfYearsTest, dayOfMonthsTest, hourOfDaysTest, dayOfWeeksTest, testHistoricalValues1, testHistoricalValues2)
net.results <- compute(net.model, testdata) 
# print(net.results)
temp = as.vector(net.results$net.result)
# temp = 1:10;
recoverDataFunc <- function(m, minVal, maxVal){m*(maxVal-minVal)+minVal}
predictedValues = recoverDataFunc( temp, valMin, valMax)
expectedValues  = values[seq(trainingDuration+futureSteps+1, totalDuration)]

# predictedValues <- predictedValues + mean(expectedValues - predictedValues)

errors <- expectedValues - predictedValues

folder <- "/errors/VAR/"
## Save to files
if (IS_SAVE) {
  saveFile <- paste(script.dir,folder,file_name,".mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
  saveFile
} else {
  saveFile <- paste(script.dir,folder,file_name,".t.mat", sep="")
  writeMat(saveFile, Lat=Lat,Lon=Lon ,errors=errors, day = day, futureSteps=futureSteps,
           expectedValues=expectedValues,predictedValues=predictedValues,
           matVersion="5", onWrite=NULL, verbose=FALSE)
}

## Plot to compare results:
pred_range <- range(expectedValues, predictedValues, na.rm=TRUE)

plot(c(0,testDuration), pred_range)
lines(expectedValues, lty=1, col=1)
lines(predictedValues, lty=2, col=2)

legLabels <- c("real", "Predict")
legend("topleft", leg=legLabels, lty=1:5, col=1:5)

mae = mean(abs(errors))
mae
avg_error = mean(errors)
saveFile