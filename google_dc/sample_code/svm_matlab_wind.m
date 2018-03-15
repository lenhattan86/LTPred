clear; close all; clc;

addpath('lib/libsvm-3.20/matlab');
addpath('../functions');

m12Months = (31+28+31+30+31+30+31+31+30+31+30+31)*24;
m12MonthsPlus1 = (31+29+31+30+31+30+31+31+30+31+30+31)*24;
m3Months = (31+28+31)*24;
m5Months = (31+28+31+30+31)*24;
m6Months = (31+28+31+30+31+30)*24;
m8Months = (31+28+31+30+31+30+31+31)*24;
m1Month = 31*24;

duration = m8Months;
test_duration = 90*24;

year = 2007; % 2012 no Feb. 29
dt_start = datetime(year,1,1,00,00,00);
dt_end = datetime(year,12,31,23,00,00);
hours = (dt_end-dt_start);
dt_current = dt_start;
idx = 2;
while dt_current <= dt_end   
    daysOfMonth(idx,1) = day(dt_current);
    hoursOfDay(idx,1)  = hour(dt_current);
    one_hour = hours(1)/8759;
    dt_current = dt_current + one_hour;   
    idx = idx + 1;
end

%test_duration = (30+31+30+31)*24;

trainDuration = 1:duration;
testDuration = duration+1:duration+test_duration;
% testDuration = trainDuration;

stateIdx = 3;
stateSAMWind = cellstr([  'NREL_SAM\WIND\AL_34.65_-86.783.csv ' ... \NREL_SAM\WIND\AL_34.65_-86.783.csv
                              ; 'NREL_SAM\WIND\GA_33.65_-84.433.csv ' ...
                              ; 'NREL_SAM\WIND\IA_41.017_-94.367.csv' ...
                              ; 'NREL_SAM\WIND\NC_35.733_-81.383.csv' ...
                              ; 'NREL_SAM\WIND\OK_36.2_-95.883.csv  ' ...
                              ; 'NREL_SAM\WIND\OR_45.55_-122.4.csv  ' ...
                              ; 'NREL_SAM\WIND\SC_33.967_-80.467.csv' ...
                              ]);
latArray = [34.65 33.65 41.017 35.733 36.2 45.55 33.967];
Lat = latArray(stateIdx);
lonArray = [-86.783 -84.433 -94.367 -81.383 -95.883 -122.4 -80.467];
Lon = lonArray(stateIdx);                          
                          
% Load data
% importDataScript
[DateTimes,AirtemperatureC,PowergeneratedbysystemkW,Pressureatm,Winddirectiondeg,Windspeedms1]  ...
                    = importSAMWind(stateSAMWind{stateIdx});


allData =   [AirtemperatureC,Pressureatm,Winddirectiondeg,Windspeedms1];

numClass = 100;
scale_factor = max(PowergeneratedbysystemkW)/numClass;
PowergeneratedbysystemkW = PowergeneratedbysystemkW./scale_factor;

labels = round(PowergeneratedbysystemkW(trainDuration));
values = allData(trainDuration,:);
testLabels = round(PowergeneratedbysystemkW(testDuration));
testValues = allData(testDuration,:);

% save data as input file  for libsvm
%The format of training and testing data file is:
%<label> <index1>:<value1> <index2>:<value2> ...
libsvmWindows = 'lib\libsvm-3.20\windows\';
libsvmTools= 'lib\libsvm-3.20\tools\';
files = cellstr([   'AL_34.65_-86.783_WIND  ' ...
                  ; 'GA_33.65_-84.433_WIND  ' ...
                  ; 'IA_41.017_-94.367_WIND ' ...
                  ; 'NC_35.733_-81.383_WIND ' ...
                  ; 'OK_36.2_-95.883_WIND   ' ...
                  ; 'OR_45.55_-122.4_WIND   ' ...
                  ; 'SC_33.967_-80.467_WIND ' ...
                  ]);
trainDataFile = files{stateIdx};
testDataFile = [files{stateIdx} '.t' ];

%%
writeLibsvmData(trainDataFile, labels, values);
writeLibsvmData(testDataFile, testLabels, testValues);
% libsvmwrite(trainDataFile, labels, values)
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
%find the best C and gamma
% commandStr = ['python ' libsvmTools  'grid.py  ' trainDataFile '.scale'];
% cmd(commandStr, true)
% disp('grid.py done!');
% return;

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
% class = 100
% AL -c 32768.0  -g 0.03125 for 100
% GA -c 32768.0  -g 0.03125 for 100
% IA -c 32768.0  -g 0.125 for 100
% NC -c 32768.0  -g 0.03125 
% OK -c 32768.0  -g 0.03125 
% OR -c 32768.0  -g 0.03125 
% SC -c 32768.0  -g 0.03125 
model = svmtrain(scale_label, scale_inst, '-t 2 -c 32768.0  -g 0.125 -q');
% Use the SVM model to classify the data
[predict_label, accuracy, probability_values] = svmpredict(scale_test_label, scale_test_inst, model);
%%
close all;
day = 1;
range = (day-1)*24+1: day*24+24*30;
predictedValues = predict_label*scale_factor;
plot(predictedValues(range));
hold on;
expectedValues = PowergeneratedbysystemkW(testDuration)*scale_factor;
plot(expectedValues(range));
legend('predict','real');
errors = predictedValues - expectedValues;
%%
save(['errors/SVM/WIND/' trainDataFile '.mat'], 'predictedValues' , 'expectedValues', 'accuracy', 'errors', 'Lat', 'Lon' );