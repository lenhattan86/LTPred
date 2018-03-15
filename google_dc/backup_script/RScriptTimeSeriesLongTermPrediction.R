rm(list=ls())
# Load packages & initialization
#install.packages("forecast")
#install.packages("R.matlab")
install.packages("tsDyn")
#library(forecast)
#library(R.matlab)
library(tsDyn)

# Load solar data 
script.dir <- dirname(sys.frame(1)$ofile)
path <- "/PV/AL_PV_2006/"
file_name <- "Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv"
file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)
fileData = read.csv(file_path, header = TRUE)
localTime = fileData[[1]]
powerMW = fileData[[2]]
# Averaging data
T_avg <- 12
dataLen <-  length(powerMW)
PowerMW_avg  <-  matrix(powerMW, nrow = T_avg, byrow = FALSE)
PowerMW_avg <-  colMeans(PowerMW_avg)
# Prediction paramters
pastSteps <- 60 #30*24 # days of 24 hours

futureSteps <- 30 # days of 24 hours
futureDuration <- 30*24;
#futureSteps <- 24
trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 9 months.
#trainingDuration <- (30)*24 # 
testDuration <- 24*15 #3*30*24
period = 1;

mod.linear <- linear(log(lynx), m=2)
mod.linear
summary(mod.linear)

#PowerMW_avg_ts = ts(PowerMW_avg[1821:1934], start=1821, end = 1934);
PowerMW_avg_ts = ts(PowerMW_avg, start=1, end = trainingDuration+testDuration);

x.train <- window(PowerMW_avg_ts, end = trainingDuration)
x.test <- window(PowerMW_avg_ts, start = trainingDuration+1)

steps = 24*30;

### Use different forecasting methods:

mod.set <- linear(x.train, m=7, d=24, steps=steps)
# mod.set <- nnetTs(x.train, m=7, d=24, steps=steps,size = 1)
# mod.set <- setar(x.train, m=2, thDelay=0)
# mod.set <- lstar(x.train, m=7, d=24, steps=steps)
# mod.set <- star(x.train, m=7, d=24, steps=steps,size = 1)
# mod.set <- aar(x.train, m=7, d=24, steps=steps)

pred_setar_naive <- predict(mod.set, n.ahead=testDuration)
#pred_setar_boot <- predict(mod.set, n.ahead=testDuration, type="bootstrap", n.boot=200)
#pred_setar_Bboot <- predict(mod.set, n.ahead=testDuration, type="block-bootstrap", n.boot=200)
#pred_setar_MC <- predict(mod.set, n.ahead=testDuration, type="bootstrap", n.boot=200)

## Plot to compare results:
#pred_range <- range(pred_setar_naive, pred_setar_boot$pred, pred_setar_MC$pred, na.rm=TRUE)
pred_range <- range(x.test,pred_setar_naive, na.rm=TRUE)
plot(x.test, ylim=pred_range, main="Comparison of forecasts methods from same SETAR")
lines(pred_setar_naive, lty=2, col=2)
#lines(pred_setar_boot$pred, lty=3, col=3)
#lines(pred_setar_Bboot$pred, lty=4, col=4)
#lines(pred_setar_MC$pred, lty=5, col=5)
#legLabels <- c("Observed", "Naive F", "Bootstrap F","Block-Bootstrap F", "MC F")
legLabels <- c("Real", "Predict")
legend("bottomleft", leg=legLabels, lty=1:5, col=1:5)