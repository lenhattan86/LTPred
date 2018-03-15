clear; close all; clc;

addpath('../lib/libsvm-3.20/matlab');
addpath('../functions');

RUN_GRID_PY = 0;
RUN_EASY_PY = 0;
IS_SAVE = true;
savePath = 'errors/SVM/WIND/';

numOfMonth = 12;
numHoursPerDay = 24;
lags = 7;
LAGS = lags*numHoursPerDay;
day_ahead = 30*numHoursPerDay;
train_duration = 2*365*numHoursPerDay;
test_duration =  300*numHoursPerDay;
total_duration = LAGS + day_ahead + train_duration + test_duration;
train_test_duration = train_duration+test_duration;

trainDuration = 1:train_duration;
testDuration = train_duration+1:train_test_duration;
labelDuration = LAGS + day_ahead + 1: LAGS + day_ahead + train_test_duration;

path = 'NREL_SAM/WIND/';

% fileName  = 'CA_037.00_-120.00_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'32.0', '8.0'};
% Percentile = 100;

% fileName  = 'FL_027.77_-081.69_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'512.0', '0.03125'};
% Percentile = 100;

% todo: run grid.py
% fileName  = 'ND_047.53_-099.78_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'32.0', '8.0'};
% Percentile = 100;

% fileName  = 'NE_041.13_-098.27_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'32.0', '8.0'};
% Percentile = 100;


% fileName  = 'NY_042.17_-074.95_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'32.0', '8.0'};
% Percentile = 100;
% 
% fileName  = 'TX_031.05_-097.56_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'32.0', '8.0'};
% Percentile = 100;

% fileName  = 'WA_047.40_-121.49_merge.csv'; 
% Lat = fileName(4:9); Lon = fileName(11:17); 
% svm_paramters = {'32.0', '8.0'};
% Percentile = 100;

fileName  = 'AL_34.65_-86.783_merge.csv'; 
Lat = fileName(4:8); Lon = fileName(10:16); 
svm_paramters = {'32.0', '2.0'};
Percentile = 100;

                       
% Load data
%importDataScript
   
[datetimeTemp,AirtemperatureC,values,Pressureatm,Winddirectiondeg,Windspeedms1]  ...
                        = importSAMWind(strcat(path, fileName), 2, total_duration+1);
                    
% datetimes = cell2mat(datetimeTemp);
datetimes = datetime(datetimeTemp,'InputFormat','MMM d, h:mm a');

pastValues = zeros(train_test_duration, lags);
for iLag = 1:lags
    pastValues(:,iLag) = values((iLag-1)*24+1: (iLag-1)*24 + train_test_duration);
end

monthOfYears = month(datetimes(labelDuration));
dayOfMonths  = day(datetimes(labelDuration));
hourOfDays   = hour(datetimes(labelDuration));
% dayOfWeeks   = weekday(datetimes(labelDuration,1:10));

avgMonthlyValues = zeros(numOfMonth,train_duration);
avgPastValues = mean(pastValues,2);

% allData = [pastValues, monthOfYears, dayOfMonths, hourOfDays];
% allData = [pastValues, dayOfMonths, hourOfDays];
% allData = [pastValues, monthOfYears, hourOfDays];
allData = [avgPastValues, monthOfYears, dayOfMonths, hourOfDays];

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
if IS_SAVE
    save([savePath fileName '.mat'], 'predictedValues' , 'expectedValues', 'accuracy', 'errors', 'Lat', 'Lon' );
    fileName
end