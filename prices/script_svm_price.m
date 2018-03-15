clear; close all; clc;

addpath('../lib/libsvm-3.20/matlab');
addpath('../functions');

RUN_GRID_PY = 0;
RUN_EASY_PY = 0;
IS_SAVE = 1;
savePath = 'errors/SVM/';

numOfMonth = 12;
numHoursPerDay = 24;
lags = 7;
LAGS = lags*numHoursPerDay;
day_ahead = 30*numHoursPerDay;
train_duration = 2*365*numHoursPerDay;
test_duration = 300*numHoursPerDay;
total_duration = LAGS + day_ahead + train_duration + test_duration;
train_test_duration = train_duration+test_duration;

trainDuration = 1:train_duration;
testDuration = train_duration+1:train_test_duration;
labelDuration = LAGS + day_ahead + 1: LAGS + day_ahead + train_test_duration;
minVal = 0;

path = 'sigcomm09-energydb\data\';

% fileName  = 'price_0029.76_-095.36_tx.houston.csv'; 
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'8192.0', '8.0'}; % svm_paramters = {'2048', '0.5'}; %svm_paramters = {'8.0', '0.125'};% 
% Percentile = 98;  

% fileName  = 'price_0037.34_-121.91_ca.np15.csv'; 
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'8192', '8.0'};
% Percentile = 98;


% at OHIO, the price in that last year suddenlly drops and has negative values. => hard to predict
% fileName  = 'price_0039.66_-082.01_pjm.ohio.csv'; 
% minVal = -50;
% Lat = fileName(7:13); Lon = fileName(15:21); 
% %svm_paramters = {'2.0', '8.0'};
% svm_paramters = {'32.0', '2.0'}; % include past data
% Percentile = 98;

% at MINN, the prices can be negative
% minVal = -20;
% fileName  = 'price_0044.96_-093.16_miso.minn.csv'; 
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'8.0', '2.0'}; % for both
% Percentile = 99;

% fileName  = 'price_0040.54_-074.40_pjm.nj.csv'; 
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'2.0', '8.0'};
% Percentile = 98;

% fileName  = 'price_0040.75_-074.00_ny.nyc.csv'; 
% minVal = -10;
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'2.0', '8.0'};
% Percentile = 99;

% at CHI, it is hard to predict the prices because the prices drop in last
% year.
% fileName  = 'price_0041.85_-087.63_pjm.chi.csv'; 
% minVal = -20;
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'2.0', '8.0'};
% Percentile = 99;

% ================ update ======================
% fileName  = 'price_0042.36_-071.06_ne.bos.csv'; 
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'2.0', '8.0'};
% Percentile = 98;

fileName  = 'price_0043.23_-071.56_ne.nh.csv'; 
Lat = fileName(7:13); Lon = fileName(15:21); 
svm_paramters = {'2.0', '8.0'};
Percentile = 98;

% fileName  = 'price_0042.89_-078.89_ny.west.csv'; 
% Lat = fileName(7:13); Lon = fileName(15:21); 
% svm_paramters = {'2.0', '8.0'};
% Percentile = 98;

% Load data
%importDataScript
[datetimeTemp,values] = importaPricefile(strcat(path, fileName), 1, total_duration);
datetimes = cell2mat(datetimeTemp);

pastValues = zeros(train_test_duration, lags);
for iLag = 1:lags
    pastValues(:,iLag) = values((iLag-1)*24+1: (iLag-1)*24 + train_test_duration);
end

monthOfYears = str2num(datetimes(labelDuration,6:7));
dayOfMonths  = str2num(datetimes(labelDuration,9:10));
hourOfDays   = str2num(datetimes(labelDuration,12:13));
dayOfWeeks   = weekday(datetimes(labelDuration,1:10));

avgMonthlyValues = zeros(numOfMonth,train_duration);

avgPastValues = mean(pastValues,2);

% allData = [pastValues, monthOfYears, dayOfMonths, hourOfDays, dayOfWeeks];
% allData = [ monthOfYears, dayOfMonths, hourOfDays, dayOfWeeks];
allData = [avgPastValues, monthOfYears, dayOfMonths, dayOfWeeks, hourOfDays];

% TODO: adjust the upper bound for prices

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
% find the best C and gamma
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
% good: -c 2048 -g 0.5
model = svmtrain(scale_label, scale_inst, ['-t 2 -c ' svm_paramters{1} ' -g ' svm_paramters{2} ' -q']);
%% Predict
% Use the SVM model to classify the data
[predict_label, accuracy, probability_values] = svmpredict(scale_test_label, scale_test_inst, model);
% [predict_label, accuracy, probability_values] = svmpredict(scale_label, scale_inst, model);
%%
close all;
iDay = 1;numOfDays = 5;
range = 1: 7*24;
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
% iDay = 1;numOfDays = 5;l
% range = 1: 15*24;
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