# Load packages & initialization

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
pastSteps <- 3*30*24 # 3 months
futureSteps <- 30*24 # 1 months
trainingDuration <- 9*30*24 # 9 months.
testDuration <- 3*30*24 # 3 months

# Training

# Predict K ahead

# Plot results

# Save results to files.

# fit an ARIMA model of order P, D, Q
