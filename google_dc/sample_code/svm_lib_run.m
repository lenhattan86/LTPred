clear; close all; clc;

addpath('lib/libsvm-3.20/matlab');
addpath('../functions');
importDataScript
%%

m12Months = (31+28+31+30+31+30+31+31+30+31+30+31)*24;
m12MonthsPlus1 = (31+29+31+30+31+30+31+31+30+31+30+31)*24;
m3Months = (31+28+31)*24;
m5Months = (31+28+31+30+31)*24;
m1Month = 31*24;

m6Months = (31+28+31+30+31+30)*24;

duration = m6Months;
test_duration = m1Month;

trainDuration = 1:duration;
%testDuration = duration+1:duration+test_duration;
testDuration = trainDuration;

%%
allData = [GlobalhorizontalirradianceWm2];
% allData = [BeamirradianceWm2]; % no
% allData = [GlobalhorizontalirradianceWm2, AmbienttemperatureC];
% allData = [AmbienttemperatureC, GlobalhorizontalirradianceWm2, Angleofincidencedeg]; 
% allData = [AmbienttemperatureC, GlobalhorizontalirradianceWm2, Angleofincidencedeg];
% allData = [AmbienttemperatureC, GlobalhorizontalirradianceWm2, Angleofincidencedeg, BeamirradianceWm2, DiffuseirradianceWm2, Shadingfactorforbeamradiation];
% allData = [AmbienttemperatureC, GlobalhorizontalirradianceWm2, Angleofincidencedeg, BeamirradianceWm2, DiffuseirradianceWm2, Shadingfactorforbeamradiation, Sunupoverhorizon01];
% allData = [AmbienttemperatureC, GlobalhorizontalirradianceWm2, Angleofincidencedeg, BeamirradianceWm2, DiffuseirradianceWm2, Shadingfactorforbeamradiation, Sunupoverhorizon01];


labels = round(PowergeneratedbysystemkW(trainDuration)* 100);
values = allData(trainDuration,:);
testLabels = round(PowergeneratedbysystemkW(testDuration) * 100);
testValues = allData(testDuration,:);
% save data as input file  for libsvm
%The format of training and testing data file is:
%<label> <index1>:<value1> <index2>:<value2> ...
libsvmWindows = 'lib\libsvm-3.20\windows\';
libsvmTools= 'lib\libsvm-3.20\tools\';
trainDataFile = 'solar2';
testDataFile = 'solar2.t';
writeLibsvmData(trainDataFile, labels, values);
writeLibsvmData(testDataFile, testLabels, testValues);
% libsvmwrite(trainDataFile, labels, values)
% libsvmwrite(testDataFile, testLabels, testValues)

%% easy.py
commandStr = ['python ' libsvmTools  'easy.py  ' trainDataFile ' ' testDataFile];
cmd(commandStr,true);
disp('easy.py done!');
% return;
%%

% Check data using tools/checkdata.py
commandStr = ['python ' libsvmTools 'checkdata.py ' trainDataFile];
cmd(commandStr);
commandStr = ['python ' libsvmTools 'checkdata.py ' testDataFile];
cmd(commandStr);

% Scale data
% svm-scale -l -1 -u 1 -s range train > train.scale
commandStr = [libsvmWindows  'svm-scale -l -1 -u 1 -s range '  trainDataFile ' > ' trainDataFile '.scale'];
cmd(commandStr);
commandStr = [libsvmWindows 'svm-scale -r range ' testDataFile ' > ' testDataFile '.scale'];
cmd(commandStr);
% % Use easy.py script
% commandStr = [libsvmWindows  'svm-scale -l -1 -u 1 -s range '  testDataFile ' > ' testScaleFile];
% cmd(commandStr);

%%  python grid.py svmguide1.scale
% find the best C and gamma
% commandStr = ['python ' libsvmTools  'grid.py  ' trainScaleFile];
% cmd(commandStr);
% disp('grid.py done!');
% return;

%%
% ./svm-train svmguide1.scale
commandStr = [libsvmWindows  'svm-train -t 2 -c 2048 -g 8.0 -q '  trainDataFile '.scale'];
%commandStr = [libsvmPath  'svm-train heart_scale'];
cmd(commandStr, true);

% ./svm-predict svmguide1.t.scale svmguide1.scale.model svmguide1.t.predict
commandStr = [libsvmWindows  'svm-predict ' testDataFile '.scale' ' ' trainDataFile '.scale' '.model ' testDataFile '.predict'];
cmd(commandStr, true);

% model = svmtrain(PowergeneratedbysystemkW(trainDuration), allData(trainDuration,:) , '-t 2 -c 256 -g 0.015625 -p 0.001953125 -q ');
% [predict_output, accuracy, dec_values] = svmpredict(PowergeneratedbysystemkW(testDuration),allData(testDuration,:) , model); % test the training data
% predict_output = predict_output - min(predict_output);

%%
% close all;
% day = 1;
% range = (day-1)*24+1: day*24+24*10;
% plot(predict_output(range));
% hold on;
% plot(PowergeneratedbysystemkW(range));
% legend('predict','real');
%%