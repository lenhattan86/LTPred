library(partsm)

script.dir <- dirname(sys.frame(1)$ofile)
path <- "/NREL_SAM/WIND/"
# file_name <- "AL_34.65_-86.783.csv"; Lon <- as.numeric(substr(file_name, 4, 8)); Lat <- as.numeric(substr(file_name, 10, 16));
# file_name <- "GA_33.65_-84.433.csv"; Lon <- as.numeric(substr(file_name, 4, 8)); Lat <- as.numeric(substr(file_name, 10, 16));
# file_name <- "IA_41.017_-94.367.csv"; Lon <- as.numeric(substr(file_name, 4, 9)); Lat <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NC_35.733_-81.383.csv"; Lon <- as.numeric(substr(file_name, 4, 9)); Lat <- as.numeric(substr(file_name, 11, 16));
# file_name <- "OK_36.2_-95.883.csv"; Lon <- as.numeric(substr(file_name, 4, 7)); Lat <- as.numeric(substr(file_name, 9, 15));
# file_name <- "OR_45.55_-122.4.csv"; Lon <- as.numeric(substr(file_name, 4, 8)); Lat <- as.numeric(substr(file_name, 10, 14));
# file_name <- "SC_33.967_-80.467.csv"; Lon <- as.numeric(substr(file_name, 4, 9)); Lat <- as.numeric(substr(file_name, 11, 17));

# many years
file_name <- "AL_34.65_-86.783_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 8)); Lat <- as.numeric(substr(file_name, 10, 16));
# file_name <- "GA_33.65_-84.433_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 8)); Lat <- as.numeric(substr(file_name, 10, 16));
# file_name <- "IA_41.017_-94.367_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 9)); Lat <- as.numeric(substr(file_name, 11, 17));
# file_name <- "NC_35.733_-81.383_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 9)); Lat <- as.numeric(substr(file_name, 11, 16));
# file_name <- "OK_36.2_-95.883_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 7)); Lat <- as.numeric(substr(file_name, 9, 15));
# file_name <- "OR_45.55_-122.4_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 8)); Lat <- as.numeric(substr(file_name, 10, 14));
# file_name <- "SC_33.967_-80.467_merge.csv"; Lon <- as.numeric(substr(file_name, 4, 9)); Lat <- as.numeric(substr(file_name, 11, 17));

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
delay = 24;
# embedded_dim= 60; # look back the past
embedded_dim= 60; # look back the past
futureSteps <- 30*day # days of 24 hours
trainingDuration <- (31+28+31+30+31+30+31+31+30)*24 # 8 months.
testDuration <-  90*day #3*30*24
##


# data("gergnp")
# lgergnp <- log(gergnp, base=exp(1))
lgergnp = ts(PowerMW_avg, start=1, end = trainingDuration)

# Model order selection
detcomp <- list(regular=c(0,0,0), seasonal=c(1,0), regvar=0)
aic <- bic <- Fnextp <- Fpval <- rep(NA, 4)
for(p in 1:4){
  lmpar <- fit.ar.par(wts=lgergnp, detcomp=detcomp, type="PAR", p=p)
  aic[p] <- AIC(lmpar@lm.par, k=2)
  bic[p] <- AIC(lmpar@lm.par, k=log(length(residuals(lmpar@lm.par))))
  Fout <- Fnextp.test(wts=lgergnp, detcomp=detcomp, p=p, type="PAR")
  Fnextp[p] <- Fout@Fstat
  Fpval[p] <- Fout@pval
}

#Test for periodic variation in the autoregressive parameters

dcsi <- list(regular=c(0,0,0), seasonal=c(1,0), regvar=0)
out.Fparsi <- Fpar.test(wts=lgergnp, detcomp=dcsi, p=2)
show(out.Fparsi)

dcsit <- list(regular=c(0,0,0), seasonal=c(1,1), regvar=0)
out.Fparsit <- Fpar.test(wts=lgergnp, detcomp=dcsit, p=2)
show(out.Fparsit)

#The results of the code above show that periodicity is not rejected, therefore, the test corroborates
#that a periodic model fits better to the data rather than an AR model

#Diagnostic for the fitted PAR model

par2 <- fit.ar.par(wts=lgergnp, type="PAR", p=2, detcomp=detcomp)
Fsh.out <- Fsh.test(res=residuals(par2@lm.par), s=frequency(lgergnp))
show(Fsh.out)

# Results in the code above show that seasonal heteroskedasticity is rejected at the 5% significance
# level. This analysis is very limited to validate the model and the user is suggested to
# carry out complementary tests such as Ljung-Box test for autocorrelation

out.par <- fit.ar.par(wts=lgergnp, type="PAR", detcomp=detcomp, p=2)
out.MV <- PAR.MVrepr(out.par)
out.MV

out.LR <- LRurpar.test(wts=lgergnp, detcomp=detcomp, p=2) 
show(out.LR)

Fpari1.out <- Fpari.piar.test(wts=lgergnp, detcomp=detcomp, p=2, type="PARI1")
show(Fpari1.out)

#Time varying impact of accumulation of shocks
out.piar <- fit.piar(wts=lgergnp, detcomp=detcomp, p=2)
out.MV <- PAR.MVrepr(out.piar)
out.MV

#Out-of-sample forecasts
out.pred <- predictpiar(wts=lgergnp, p=2, hpred=24)
show(out.pred)

out.pred@wts <- exp(1)^out.pred@wts
out.pred@fcast <- exp(1)^out.pred@fcast
out.pred@ucb <- exp(1)^out.pred@ucb
out.pred@lcb <- exp(1)^out.pred@lcb
plotpredpiar(out.pred)