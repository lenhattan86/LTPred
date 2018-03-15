clear; close all; clc;

addpath('lib/libsvm-3.20/matlab');
addpath('../functions');

timeSlotAnHour = 12;

train_days = 21;
test_days = 7;
avg_step = 3;
oneDay = 24;
delay = 24;

trainDuration = 1:train_days*oneDay;
testDuration = train_days*oneDay+1:train_days*oneDay+test_days*oneDay;
totalLen = (train_days+test_days)*oneDay;
trainLen = train_days*oneDay;
testLen = test_days*oneDay; 

total_duration = trainLen+testLen;

period = 7*oneDay;

stateIdx = 13;
folder = 'Akamai/'
files = cellstr([ 'AL_0034.77_-086.68_workload.csv' ...
                  ;'GA_0033.72_-084.47_workload.csv' ...
                  ;'IA_0041.58_-093.68_workload.csv' ...
                  ;'SC_0034.07_-081.19_workload.csv' ...
                  ;'OK_0035.48_-097.50_workload.csv' ...
                  ;'OR_0044.81_-122.68_workload.csv' ...
                  ;'SC_0034.07_-081.19_workload.csv' ...
                  ;'VA_0038.02_-078.57_workload.csv' ...
                  ;'TN_0036.07_-086.72_workload.csv' ...
                  ;'AR_0034.57_-092.64_workload.csv' ...
                  ;'MA_0042.35_-071.55_workload.csv' ...
                  ;'CA_0037.28_-120.45_workload.csv' ...
                  ;'NY_0041.59_-075.54_workload.csv' ...
                ]);           
          
fileName =    files{stateIdx};               
Lat = str2double(fileName(4:10));
Lon = str2double(fileName(12:18));
% Load data
%importDataScript
[datetimes,valuesTmp,fliLoad] = importWorkload([folder fileName], 1, timeSlotAnHour*total_duration);
values = mean(reshape(valuesTmp, [timeSlotAnHour total_duration]), 1);
values = values';

predictedValues = zeros(length(testDuration),1);

for i=1:testLen      
    idxList = [];
    numOfperiod = floor(trainLen/period);
    for j=1:numOfperiod
        startidx = trainLen + i - avg_step/2*oneDay+1 - period;
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
range = (day-1)*24+1: day*24;
plot(predictedValues(range));
hold on;
plot(expectedValues(range));
legend('predict','real');

%%
save(['errors/AVG/' files{stateIdx} '.mat'], 'predictedValues' , 'expectedValues', 'errors', 'Lat', 'Lon' );