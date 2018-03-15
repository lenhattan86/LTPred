clear; close all; clc;

addpath('../lib/libsvm-3.20/matlab');
addpath('../functions');

lags = 1;
numOfMonth = 12;
day = 24;
day_ahead = 1*day;
train_duration = 2*365*day;
test_duration = 14*day;
total_duration = lags + day_ahead + train_duration + test_duration;
train_test_duration = train_duration+test_duration;

trainDuration = 1:train_duration;
testDuration = train_duration+1:train_test_duration;
labelDuration = lags + day_ahead + 1: lags + day_ahead + train_test_duration;

path = 'sigcomm09-energydb\data\';

fileName  = 'price_0029.76_-095.36_tx.houston.csv'; lat = fileName(7:13); lon = fileName(15:21); svm_paramters = '32.0 2.0 10.4167';
                        
% Load data
%importDataScript
[datetimeTemp,values] = importaPricefile(strcat(path, fileName), 1, total_duration);
datetimes = cell2mat(datetimeTemp);

% TODO: adjust the upper bound for prices
valuesRange = [0 200];
values = min(values, valuesRange(2));
values = max(values, valuesRange(1));

pastValues = zeros(train_test_duration, lags);
for iLag = 1:lags
    pastValues(:,iLag) = values(iLag: iLag + train_test_duration - 1);
end

monthOfYears = str2num(datetimes(labelDuration,6:7));
dayOfMonths  = str2num(datetimes(labelDuration,9:10));
hourOfDays   = str2num(datetimes(labelDuration,12:13));
dayOfWeeks   = weekday(datetimes(labelDuration,1:10));

avgMonthlyValues = zeros(numOfMonth,train_duration);

% allData = [pastValues, monthOfYears, dayOfMonths, hourOfDays, dayOfWeeks];
allData = [ monthOfYears, dayOfMonths, hourOfDays, dayOfWeeks];
% allData = [ hourOfDays, dayOfWeeks];

numClass = 200;
scale_factor = max(values)/numClass;
scaledValues = values./scale_factor;

% need to be fixed
trainLabels = round(scaledValues(lags + day_ahead + 1: train_duration + lags + day_ahead));
trainValues = allData(trainDuration,:);
rawTestLabels = scaledValues(testDuration + lags + day_ahead);
testLabels = round(rawTestLabels);
testValues = allData(testDuration,:);

% save data as input file  for libsvm
%The format of training and testing data file is:
%<label> <index1>:<value1> <index2>:<value2> ...
libsvmWindows = '..\lib\libsvm-3.20\windows\';
libsvmTools= '..\lib\libsvm-3.20\tools\';

trainDataFile = ['svm_temp' ];
testDataFile = ['svm_temp' '.t'];

%%
writeLibsvmData(trainDataFile, trainLabels, trainValues);
writeLibsvmData(testDataFile, testLabels, testValues);
% libsvmwrite(trainDataFile, trainLabels, trainValues)
% libsvmwrite(testDataFile, testLabels, testValues)

%% easy.py % you can modify the paths in easy if compiling errors
% commandStr = ['python ' libsvmTools  'easy.py  ' trainDataFile ' ' testDataFile];
% cmd(commandStr,true);
% disp('easy.py done!');
% return;
%%

% Check data using tools/checkdata.py
commandStr = ['python ' libsvmTools 'checkdata.py ' trainDataFile];
cmd(commandStr, true);
commandStr = ['python ' libsvmTools 'checkdata.py ' testDataFile];
cmd(commandStr, true);

% Scale data
% svm-scale -l -1 -u 1 -s range train > train.scale
commandStr = [libsvmWindows  'svm-scale -l -1 -u 1 -s range '  trainDataFile ' > ' trainDataFile '.scale'];
cmd(commandStr);
commandStr = [libsvmWindows 'svm-scale -r range ' testDataFile ' > ' testDataFile '.scale'];
cmd(commandStr);
%%  python grid.py svmguide1.scale % you can modify the paths in easy if compiling errors
% find the best C and gamma
commandStr = ['python ' libsvmTools  'grid.py  ' trainDataFile '.scale'];
cmd(commandStr, true)
disp('grid.py done!');
return;

%% libsvm C++ 
% ./svm-train svmguide1.scale
% commandStr = [libsvmWindows  'svm-train -t 2 -c 32768 -g 0.5 '  trainDataFile '.scale'];
% %commandStr = [libsvmPath  'svm-train heart_scale'];
% cmd(commandStr, true);
% 
% % ./svm-predict svmguide1.t.scale svmguide1.scale.model svmguide1.t.predict
% commandStr = [libsvmWindows  'svm-predict ' testDataFile '.scale' ' ' trainDataFile '.scale' '.model ' testDataFile '.predict'];
% cmd(commandStr, true);
% return;
%% libsvm matlab
% read the data set
[scale_label, scale_inst] = libsvmread([trainDataFile '.scale']);
[scale_test_label, scale_test_inst] = libsvmread([testDataFile '.scale']);

% Train the SVM
model = svmtrain(scale_label, scale_inst, '-t 2 -c 8192 -g 00078125 -q');
% Use the SVM model to classify the data
[predict_label, accuracy, probability_values] = svmpredict(scale_test_label, scale_test_inst, model);
% [predict_label, accuracy, probability_values] = svmpredict(scale_label, scale_inst, model);
%%
close all;
iDay = 1;numOfDays = 5;
range = 1: test_duration;
predictedValues = predict_label*scale_factor;
plot(range, predict_label(range));
hold on;
plot(range, scale_test_label(range));
hold on;
expectedValues = rawTestLabels;
plot(range, expectedValues(range));
legend('predict','test label','real');
errors = predictedValues - expectedValues;
%%
% save(['errors/SVM' fileName '.mat'], 'predictedValues' , 'expectedValues', 'accuracy', 'errors', 'lat', 'lon' );