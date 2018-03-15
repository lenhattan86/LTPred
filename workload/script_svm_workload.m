clear; close all; clc;

addpath('../lib/libsvm-3.20/matlab');
addpath('../functions');

RUN_GRID_PY = 0;
RUN_EASY_PY = 0;
IS_SAVE = true;
savePath = 'errors/SVM/';

timeSlotAnHour = 12;
numOfMonth = 12;
hourPerDay = 24;
lags = 1;
LAGS = lags*hourPerDay;
day_ahead = 1*hourPerDay;
train_duration = 21*hourPerDay;
test_duration =  7*hourPerDay;
train_test_duration = train_duration+test_duration;
total_duration = LAGS + day_ahead + train_test_duration;

trainDuration = 1:train_duration;
testDuration = train_duration+1:train_test_duration;
labelDuration = LAGS + day_ahead + 1: LAGS + day_ahead + train_test_duration;

path = 'Akamai/';

% fileName  = 'AL_0034.77_-086.68_workload.csv'; 
% svm_paramters = {'128.0', '2.0'}; % for interpolation
% Percentile = 100;

% fileName  = 'GA_0033.72_-084.47_workload.csv'; 
% svm_paramters = {'8.0', '0.5'};
% Percentile = 100;

% todo: run grid.py
% fileName  = 'IA_0041.58_-093.68_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'SC_0034.07_-081.19_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'OK_0035.48_-097.50_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'OR_0044.81_-122.68_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'SC_0034.07_-081.19_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName = 'VA_0038.02_-078.57_workload.csv';
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'TN_0036.07_-086.72_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'AR_0034.57_-092.64_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName  = 'MA_0042.35_-071.55_workload.csv'; 
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

% fileName = 'CA_0037.28_-120.45_workload.csv';
% svm_paramters = {'128.0', '2.0'};
% Percentile = 100;

fileName = 'NY_0041.59_-075.54_workload.csv';
svm_paramters = {'128.0', '2.0'};
Percentile = 100;

Lat = fileName(4:10); Lon = fileName(12:18);
                       
% Load data
%importDataScript
   
[datetimeTmp,valuesTmp,fliLoad] = importWorkload([path fileName], 1, timeSlotAnHour*total_duration);
datetimeTemp = datetimeTmp(1:12:timeSlotAnHour*total_duration);
values = mean(reshape(valuesTmp, [timeSlotAnHour total_duration]), 1);
values = values';
                    
% datetimes = cell2mat(datetimeTemp);
datetimes = datetime(datetimeTemp,'InputFormat','yyyy-MM-dd HH:mm:ss');

pastValues = zeros(train_test_duration, lags);
for iLag = 1:lags
    pastValues(:,iLag) = values((iLag-1)*24+1: (iLag-1)*24 + train_test_duration);
end

monthOfYears = month(datetimes(labelDuration));
dayOfMonths  = day(datetimes(labelDuration));
hourOfDays   = hour(datetimes(labelDuration));
dayOfWeeks   = weekday(datetimes(labelDuration));

avgMonthlyValues = zeros(numOfMonth,train_duration);

avgPastValues = mean(pastValues,2);

% allData = [pastValues, hourOfDays, dayOfWeeks];
allData = [avgPastValues, hourOfDays, dayOfWeeks];
% allData = [hourOfDays, dayOfWeeks];

% TODO: adjust the upper bound for prices
minVal = 0;
values = max(values, minVal);
maxVal = prctile(values,Percentile);
values = min(values, maxVal);


numClass = 200;
scale_factor = max(values)/numClass;
scaledValues = values./scale_factor;

% need to be fixed
trainLabels = round(scaledValues(LAGS + day_ahead + 1: train_duration + LAGS + day_ahead));
trainValues = allData(trainDuration,:);
rawTestLabels = scaledValues(testDuration + LAGS + day_ahead);
expectedValues = values(testDuration + LAGS + day_ahead);
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
if RUN_EASY_PY
    commandStr = ['python ' libsvmTools  'easy.py  ' trainDataFile ' ' testDataFile];
    cmd(commandStr,true);
    disp('easy.py done!');
    return;
end
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
%find the best C and gamma
if RUN_GRID_PY
    commandStr = ['python ' libsvmTools  'grid.py  ' trainDataFile '.scale'];
    cmd(commandStr, true)
    disp('grid.py done!');
    return;
end
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
model = svmtrain(scale_label, scale_inst, ['-t 2 -c ' svm_paramters{1} ' -g ' svm_paramters{2} ' -q']);
%% Predict
% Use the SVM model to classify the data
[predict_label, accuracy, probability_values] = svmpredict(scale_test_label, scale_test_inst, model);
%%
close all;
iDay = 1;numOfDays = 5;
range = 1: 5*hourPerDay;
predictedValues = predict_label*scale_factor;
plot(range, predictedValues(range));
hold on;
plot(range, expectedValues(range));
legend('predict','real');
errorsRound = predict_label - scale_test_label;
mean(abs(errorsRound))
errors = predictedValues - expectedValues;
mean(abs(errors))
mean(abs(errors))/mean(expectedValues)*100
%%
% [predict_label, accuracy, probability_values] = svmpredict(scale_label, scale_inst, model);
% close all;
% iDay = 1;numOfDays = 5;
% range = 1: 5*hourPerDay;
% predictedValues = predict_label*scale_factor;
% expectedValues = scale_label*scale_factor;
% plot(range, predictedValues(range));
% hold on;
% plot(range, expectedValues(range));
% legend('predict','real');

%%
if IS_SAVE
    save([savePath fileName '.mat'], 'predictedValues' , 'expectedValues', 'accuracy', 'errors', 'Lat', 'Lon' );
    fileName
end