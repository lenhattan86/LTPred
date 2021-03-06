
#
#install.packages("ggplot2")

#Time series data
script.dir <- dirname(sys.frame(1)$ofile)
path <- "/sample_data/"
file_name <- "orderts.RData"
file_path = paste(script.dir,path,file_name, sep = "", collapse = NULL)

load(file_path)
head(orderts)

#Exploring the time series data

library('ggplot2')
qplot(week, orders, data = orderts, colour = as.factor(year), geom = "line")

#A by-quarter histogram of the week values uncovers the cause quickly:
qplot(week, data=orderts, colour=as.factor(year), binwidth=0.5) + facet_wrap(~ quarter)
orderts2 <- cbind(orderts[-13,], weekinq=c(1:117))
prev <- orderts2[1,]
runvar <- 1
for(i in 2:nrow(orderts2)){
  current <- orderts2[i,]
  orderts2[i,"weekinq"] <- ifelse(prev$quarter == current$quarter, runvar+1, 1)
  runvar <- ifelse(prev$quarter == current$quarter, runvar+1, 1)
  prev <- current
}
rm(prev, current, runvar, i)

# Let us compare the orders now on a quarter by quarter basis:
qplot(weekinq, orders, data = orderts2, colour = as.factor(year), geom = "line") + facet_wrap(~quarter)

# Frequency domain observations
f <- data.frame(coef = fft(orderts2[1:104, "orders"]), freqindex = c(1:104))
qplot(freqindex, Mod(coef), data = f[2:53,], geom = "line")

f[Mod(f$coef) > 3 & f$freqindex < 53, "freqindex"] - 1

peaks <- Mod(f$coef) > 3
ffilt <- f
ffilt[!peaks, "coef"] <- 0
ffilt <- data.frame(index=ffilt$freqindex, value=Re(fft(ffilt$coef, inverse=TRUE))/104, type=rep("filtered", times=104))
ffilt <- rbind(ffilt, data.frame(index=seq(1:104), value=orderts2[1:104,"orders"], type=rep("original", times=104)))


# Forecasting approach

midindex <- ceiling((length(f$coef)-1)/ 2) + 1
lindex <- length(f$coef)
peakind <- f[abs(f$coef) > 3 & f$freqindex > 1 & f$freqindex < midindex,]



lowerind <- 1

subsignals <- lapply(c(peakind$freqindex, midindex+1), function(x){
  upperind <- x
  fsub <- f
  notnullind <- ((fsub$freqindex >= lowerind
                  & fsub$freqindex < upperind)
                 |
                   (fsub$freqindex >  (lindex - upperind + 2)
                    & fsub$freqindex <= (lindex - lowerind + 2)))
  fsub[!notnullind,"coef"] <- 0
  lowerind <<- upperind
  Re(fft(fsub$coef, inverse=TRUE)/length(fsub$coef))
})

library(grid)
grid.newpage()
pushViewport(viewport(layout=grid.layout(4,2)))

vplayout <- function(x,y)
  viewport(layout.pos.row = x, layout.pos.col = y)

psig <- function(x, y, z){
  h <- data.frame(index = c(1:length(subsignals[[x]])),
                  orders = subsignals[[x]])
  lab <- paste("Subseries ", as.character(x), sep="")
  print(qplot(index, orders, data = h, geom = "line", main=lab), vp = vplayout(y,z))
  TRUE
}

psig(1,1,1); psig(2,1,2); psig(3,2,1); psig(4,2,2); psig(5,3,1); psig(6,3,2); psig(7,4,1)


# Neural network training

nn.sizes <- c(4,2,3,3,3,2,2,2)

numofsubs <- length(subsignals)
twindow <- 4

offsettedsubdfs <- lapply(1:numofsubs, function(x){
  singleoffsets <- lapply(0:(twindow-1), function(y){
    subsignals[[x]][(twindow-y):(length(subsignals[[x]])-y-1)]
  })
  a <- Reduce(cbind, singleoffsets)
  names <- lapply(1:twindow, function(y){paste("TS", as.character(x), "_", as.character(y), sep = "")})
  b <- as.data.frame(a)
  colnames(b) <- names
  b
})

sample.number <- length(offsettedsubdfs[[1]][,1])

#the neural networks
library(nnet)
nns <- lapply(1:length(offsettedsubdfs), function(i)
{
  nn <- nnet(offsettedsubdfs[[i]][1:(sample.number),], #the training samples
             subsignals[[i]][(twindow+1):(length(subsignals[[i]]))], #the output
             #corresponding to the training samples
             size=nn.sizes[i], #number of neurons
             maxit = 1000, #number of maximum iteration
             linout = TRUE) #the neuron in the output layer should be linear
  #the result of the trained networks should be plotted
  plot(subsignals[[i]][(twindow+1):(length(subsignals[[i]]))], type="l")
  lines(nn$fitted.values,type="l",col="red")
  nn
})


# Forecasting
number.of.predict <- 14

#long term prediction
long.predictions <- lapply(1:length(offsettedsubdfs), function(i)
{
  prediction <- vector(length=number.of.predict, mode="numeric")
  #initial input
  input <- offsettedsubdfs[[i]][sample.number,]
  for (j in 1 : number.of.predict)
  {
    prediction[j] <- predict(nns[[i]], input)
    input <- c(prediction[j],input[1:(length(input)-1)])
  }
  #we want to plot the prediction
  plot(c(nns[[i]]$fitted.values,prediction), type="l",col="red")
  lines(subsignals[[i]][(twindow+1):length(subsignals[[i]])])
  prediction
})

