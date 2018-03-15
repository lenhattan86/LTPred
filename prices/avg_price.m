clear; close all; clc;

addpath('lib/libsvm-3.20/matlab');
addpath('../functions');

year = 365;
train_days = 2*365;
test_days = 365;
avg_step = 30;
oneDay = 24;
delay = 24;

trainDuration = 1:train_days*oneDay;
testDuration = train_days*oneDay+1:train_days*oneDay+test_days*oneDay;
totalLen = (train_days+test_days)*oneDay;
trainLen = train_days*oneDay;
testLen = test_days*oneDay; 

period = 365*oneDay;

stateIdx = 9;
folder = 'sigcomm09-energydb\data\'
statePrices = cellstr([ 'price_0029.76_-095.36_tx.houston.csv ' ...
                      ; 'price_0037.34_-121.91_ca.np15.csv    ' ...
                      ; 'price_0039.66_-082.01_pjm.ohio.csv   ' ...
                      ; 'price_0039.94_-083.31_pjm.aep.csv    ' ...
                      ; 'price_0040.54_-074.40_pjm.nj.csv     ' ...
                      ; 'price_0040.75_-074.00_ny.nyc.csv     ' ...
                      ; 'price_0041.85_-087.63_pjm.chi.csv    ' ...
                      ; 'price_0042.36_-071.06_ne.bos.csv     ' ...
                      ; 'price_0044.96_-093.16_miso.minn.csv  ' ...
                      ]);
fileName =    statePrices{stateIdx};               
Lat = str2double(fileName(7:13));
Lon = str2double(fileName(15:21));
% Load data
%importDataScript
[datetimes,prices] = importPJMPrices(strcat(folder,statePrices{stateIdx}));

values = prices;
predictedValues = zeros(length(testDuration),1);

for i=1:testLen      
    idxList = [];
    numOfperiod = floor(trainLen/period);
    for j=1:numOfperiod
        startidx = trainLen + i-avg_step/2*oneDay+1 - period;
        endIdx = trainLen + i + avg_step/2*oneDay - period;
        tempList = max(startidx,1):oneDay:min(endIdx,totalLen);    
        idxList = [idxList tempList];    
    end    
    pastValues = values(idxList);
    predictedValues(i) = mean(pastValues);
end
expectedValues = values(testDuration);
errors = expectedValues - predictedValues;

mae = mean(abs(errors))

%%
close all;
day = 1;
range = (day-1)*24+1: day*24+24*7;
plot(predictedValues(range));
hold on;
plot(expectedValues(range));
legend('predict','real');

%%
save(['errors/AVG/' statePrices{stateIdx} '.mat'], 'predictedValues' , 'expectedValues', 'errors', 'Lat', 'Lon' );