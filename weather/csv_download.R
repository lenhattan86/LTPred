rm(list=ls())
#install.packages("RCurl")
library(RCurl)
library(MASS)
script.dir <- dirname(sys.frame(1)$ofile)

saveFile = "AL_34.05_-86.05_wunderground.csv"
startDate <-  as.Date("2005/01/01")
endDate <-  as.Date("2005/03/31")
date <-  "2015/10/13"

weatherData <-  matrix(data = NA, nrow = 1, ncol = 1)

currentDate = startDate;

while (currentDate <= endDate ){
  date = format(currentDate, format="%Y/%m/%d")
  # AL - http://www.wunderground.com/history/airport/KGAD/2015/10/13/DailyHistory.html?req_city=Reece+City&req_state=AL&req_statename=Alabama&reqdb.zip=35954&reqdb.magic=2&reqdb.wmo=99999
  # http://www.wunderground.com/history/airport/KGAD/2005/01/23/DailyHistory.html?req_city=Reece+City&req_state=AL&req_statename=Alabama&reqdb.zip=35954&reqdb.magic=2&reqdb.wmo=99999&format=1
  URL <- paste("http://www.wunderground.com/history/airport/KGAD/",
                date,
               "/DailyHistory.html?req_city=Reece+City&req_state=AL&req_statename=Alabama&reqdb.zip=35954&reqdb.magic=2&reqdb.wmo=99999&format=1"
               ,sep="")
  x <- getURL(URL)
  response <- read.csv(textConnection(x),row.names=NULL)
  if(currentDate == startDate){
    weatherData <- response
  } else {
    weatherData <-  rbind(weatherData, response)
  }
  currentDate <- currentDate+1;
}

destFile = paste(script.dir,"/data/",saveFile,sep="")
write.matrix(format(weatherData, scientific=FALSE), file = destFile, sep=",")
#download.file(url,destFile,method="libcurl")