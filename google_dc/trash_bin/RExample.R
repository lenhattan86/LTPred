# Install packages if not available.
#install.packages("astsa") # install it ... you'll be asked to choose the closest CRAN mirror
#install.packages("dynlm");

require(astsa)            # then load it (has to be done at the start of each session)

data(jj)  # load the data - you don't have to do this anymore with astsa, but you do in general
jj        # print it to the screen

ls()         # list your objects

rm(worry)    # remove your worry object

options(digits=2)  # the default is 7, but it's more than I want now
(zardoz = ts(rnorm(48), start=c(2293,6), frequency=12))
# use window() if you want a part of a ts object
(oz = window(zardoz, start=2293, end=c(2295,12)))

time(jj)
cycle(jj)
plot(jj, ylab="Earnings per Share", main="J & J")   
plot(jj, type="o", col="blue", lty="dashed")
plot(diff(log(jj)), main="logged and diffed") 

x = -5:5                  # sequence of integers from -5 to 5
y = 5*cos(x)              # guess
par(mfrow=c(3,2))         # multifigure setup: 3 rows, 2 cols
#---  plot:
plot(x, main="plot(x)")
plot(x, y, main="plot(x,y)")
#---  plot.ts:
plot.ts(x, main="plot.ts(x)")
plot.ts(x, y, main="plot.ts(x,y)")
#---  ts.plot:
ts.plot(x, main="ts.plot(x)")
ts.plot(ts(x), ts(y), col=1:2, main="ts.plot(x,y)")  # note- x and y are ts objects 
#---  the help files [? and help() are the same]:

help(ts.plot)

k = c(.5,1,1,1,.5)            # k is the vector of weights
(k = k/sum(k))       
fjj = filter(jj, sides=2, k)  # ?filter for help [but you knew that already]
plot(jj)
lines(fjj, col="red")         # adds a line to the existing plot
lines(lowess(jj), col="blue", lty="dashed")

dljj = diff(log(jj))        # difference the logged data
plot(dljj)                  # plot it (not shown)
shapiro.test(dljj)
#W = 0.9725, p-value = 0.07211
#sanity.clause(dljj)         # test for sanity
#SC = 45.57, p-value = 0.0003    

par(mfrow=c(2,1))        # set up the graphics 
hist(dljj, prob=TRUE, 12)   # histogram    
lines(density(dljj))     # smooth it - ?density for details 
qqnorm(dljj)             # normal Q-Q plot  
qqline(dljj)             # add a line 

# I couldn't fool you - there ain't no sanity clause 

par(mfrow=c(2,1))        # set up the graphics 
hist(dljj, prob=TRUE, 12)   # histogram    
lines(density(dljj))     # smooth it - ?density for details 
qqnorm(dljj)             # normal Q-Q plot  
qqline(dljj)

lag.plot(dljj, 9, do.lines=FALSE)  # see Issue 5 for Rs definition of lag, which is not what you think it is...
lag1.plot(dljj, 9)  # a better plot if you have astsa loaded (not shown) 
# why the do.lines=FALSE? Because you get a phase plane if it's TRUE 
#   a little phase plane aside - try this on your own
x = cos(2*pi*1:100/4) + .2*rnorm(100)
plot.ts(x)
dev.new()
lag.plot(x, 4)

par(mfrow=c(2,1)) # The power of accurate observation is commonly called cynicism 
#     by those who have not got it. - George Bernard Shaw
acf(dljj, 20)     # ACF to lag 20 - no graph shown... keep reading
pacf(dljj, 20)    # PACF to lag 20 - no graph shown... keep reading
# !!NOTE!! acf2 on the line below is ONLY available in astsa and tsa3
acf2(dljj)        # this is what you'll see below

plot(dog <- stl(log(jj), "per")) 


Q = factor(cycle(jj))   # make (Q)uarter factors
trend = time(jj)-1970   # not necessary to "center" time, but the results look nicer
reg = lm(log(jj)~0+trend+Q, na.action=NULL)  # run the regression without an intercept
summary(reg)

model.matrix(reg)

plot(log(jj), type="o")   # the data in black with little dots 
lines(fitted(reg), col=2) # the fitted values in bloody red - or use lines(reg$fitted, col=2)

par(mfrow=c(2,1))
plot(resid(reg))      # residuals - reg$resid is same as resid(reg) 
acf(resid(reg),20)    # acf of the resids 

require(astsa)
data(cmort, part)
ded = ts.intersect(cmort,part,part4=lag(part,-4))              # align the series first
fit = lm(cmort~part+part4, data=ded, na.action=NULL)           # now the regression will work
summary(fit) 

require(dynlm)                          # load the package
fit = dynlm(cmort~part + lag(part,-4))  # assumes cmort and part are ts objects, which they are
# fit = dynlm(cmort~part + L(part,4))  is the same thing.
summary(fit)

# some AR1s 
x1 = arima.sim(list(order=c(1,0,0), ar=.9), n=100) 
x2 = arima.sim(list(order=c(1,0,0), ar=-.9), n=100)
par(mfrow=c(2,1))
plot(x1, main=(expression(AR(1)~~~phi==+.9)))  # ~ is a space and == is equal  
plot(x2, main=(expression(AR(1)~~~phi==-.9)))
dev.new()           # open another graphics device if you wish
acf2(x1, 20)
dev.new()           # and another
acf2(x2, 20)  # recall acf2 belongs to astsa...  
#  ... if it's not loaded, then you would have to do something like:
par(mfrow=c(2,1)); acf(x1); pacf(x1) 

# an MA1  
x = arima.sim(list(order=c(0,0,1), ma=.8), n=100)
plot(x, main=(expression(MA(1)~~~theta==.8)))
dev.new()
acf2(x)

# an AR2 
x = arima.sim(list(order=c(2,0,0), ar=c(1,-.9)), n=100) 
plot(x, main=(expression(AR(2)~~~phi[1]==1~~~phi[2]==-.9)))
dev.new()
acf2(x)

# an ARIMA(1,1,1) 
x = arima.sim(list(order=c(1,1,1), ar=.9, ma=-.5), n=200)
plot(x, main=(expression(ARIMA(1,1,1)~~~phi==.9~~~theta==-.5)))
dev.new()         # the process is not stationary, so there is no population [P]ACF ...
acf2(x, 30)   # but look at the sample values to see how they differ from the examples above

x = arima.sim(list(order=c(1,0,1), ar=.9, ma=-.5), n=100) # simulate some data
(x.fit = arima(x, order = c(1, 0, 1)))   # fit the model and print the results

tsdiag(x.fit, gof.lag=20) # don't use this - it's partially WRONG

x.fore = predict(x.fit, n.ahead=10)  
# plot the forecasts
U = x.fore$pred + 2*x.fore$se
L = x.fore$pred - 2*x.fore$se
minx=min(x,L)
maxx=max(x,U)
ts.plot(x,x.fore$pred,col=1:2, ylim=c(minx,maxx))
lines(U, col="blue", lty="dashed")
lines(L, col="blue", lty="dashed") 

require(astsa)   # if it's not loaded already
plot(gtemp)      # graph the series (not shown here) 

arima(gtemp, order=c(1,1,1)) 

arima(diff(gtemp), order=c(1,0,1))  # diff the data and fit an arma to the diffed data

sarima(gtemp, 1, 1, 1) # partial output shown (easy, huh?)

trend = time(cmort)       # assumes cmort and part are there from previous examples
fit.lm = lm(cmort~trend + part)  # ols
acf2(resid(fit.lm))       # check acf and pacf of the resids     
# resids appear to be AR(2) 

(fit = arima(cmort, order=c(2,0,0), xreg=cbind(trend, part))) 
Box.test(resid(fit), 12, type="Ljung", fitdf = 2)  # check whiteness via Q- statistic

x = arima.sim(list(order=c(2,0,0), ar=c(1,-.9)), n=2^8) # some data
par(mfcol=c(2,2))
plot.ts(x, main="da data")  
mvspec(x, spans=c(5,5), plot=TRUE, taper=.1, log="no") # nonparametric spectral estimate                           
# spec.pgram(x, spans=c(5,5), log="no")  # same using stats package; also see spectrum()
spec.ar(x, log="no")                     # parametric spectral estimate
arma.spec(ar = c(1,-.9), log="no")       # model spectral density 

per = abs(fft(x-mean(x)))^2/length(x)  # Mod() and abs() same here 
# if you want a nice picture: 
freq = (1:length(x)-1)/length(x)
plot(freq, per, type="h")