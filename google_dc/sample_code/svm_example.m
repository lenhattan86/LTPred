clc; clear; close all; 
%%
% Add class paths

addpath('lib/libsvm-3.20/matlab');
addpath('../functions');

m12Months = (31+28+31+30+31+30+31+31+30+31+30+31)*24;
m12MonthsPlus1 = (31+29+31+30+31+30+31+31+30+31+30+31)*24;
m3Months = (31+28+31)*24;
m5Months = (31+28+31+30+31)*24;
m1Month = 31*24;
duration = m5Months;

test_duration = m1Month;

%% Load training data
% INCLUDE_DATE = true;
% trainWeatherFile = '..\renewable\noaa_weather\AL\csv\723235-13896-2005.gz.csv';
% temp = cell2mat(importNWSData(trainWeatherFile, 2));
% [C, rows, ic] = unique(temp(:,4:6),'rows');
% temp = temp(rows,:);
% temp(:,12) = filterNoise(temp(:,12),999.9, [-inf 100]);
% temp(:,13) = filterNoise(temp(:,13),99999, [-inf 5000]);
% temp(:,13) = filterNoise(temp(:,13),22000, [-inf 5000]);
% temp(:,14) = filterNoise(temp(:,14),999.9, [-inf 100]);
% temp(:,15) = filterNoise(temp(:,15),999.9, [-inf 100]);
% temp(:,16) = filterNoise(temp(:,16),9999.9,[-100 5000]);
% if INCLUDE_DATE
%     cols = [4:6 12:16];
%     % cols = [4:5 12:16];
%     %cols = [4 5 6 12 13]; % 13, 14, 15
%     % cols = [4:6];
% else
%     cols = [12:16];
% end
% weatherData = temp(:,cols);

weatherData = importSolarAnywhere('solar_anywhere/SiteName SolarAnywhere Time Series 2006 to 200612310000 Lat_34_65 Lon_-86_75 TMY3 format.csv');
weatherData = weatherData(:,[5 11]);

[LocalTime, PowerMW] = importPV('PV/AL_PV_2006/DA_34.05_-86.05_2006_DPV_36MW_60_Min.csv',2, 105121);
solarMW_avg = PowerMW;

%% Load Test data
% testWeatherFile = '../renewable/noaa_weather/AL/csv/723235-13896-2006.gz.csv';
% temp = cell2mat(importNWSData(testWeatherFile, 2));
% [C, rows, ic] = unique(temp(:,4:6),'rows');
% temp = temp(rows,:);
% temp(:,12) = filterNoise(temp(:,12),999.9, [-inf 100]);
% temp(:,13) = filterNoise(temp(:,13),99999, [-inf 5000]);
% temp(:,13) = filterNoise(temp(:,13),22000, [-inf 5000]);
% temp(:,14) = filterNoise(temp(:,14),999.9, [-inf 100]);
% temp(:,15) = filterNoise(temp(:,15),999.9, [-inf 100]);
% temp(:,16) = filterNoise(temp(:,16),9999.9,[-100 5000]);
% testWeatherData = temp(:,cols);
% 
[LocalTime, PowerMW] = importPV('PV/AL_PV_2006/Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv',2, 105121);
% Averaging data
T_avg = 12;
dataLen = length(PowerMW);
testSolarMW_avg = mean(reshape(PowerMW,[T_avg,dataLen/T_avg]));
testSolarMW_avg = testSolarMW_avg';



%% run SVM
trainDuration = 1:duration;
testDuration = duration+1:duration+test_duration;
% testSolarMW_avg = solarMW_avg;

svm_label = round(testSolarMW_avg(trainDuration)*10);
svm_inst = weatherData(trainDuration,:);
%svm_inst = solarMW_avg(trainDuration,:);

expected_output = testSolarMW_avg(testDuration);
svm_input = weatherData(testDuration,:);

% model = svmtrain(svm_label, svm_inst, '-c 1 -g 0.07 -b 1');
% [predict_output, accuracy, dec_values] = svmpredict(expected_output, svm_input, model, '-b 1'); % test the training data

model = svmtrain(svm_label, svm_inst, '-t 2');
[predict_output, accuracy, dec_values] = svmpredict(expected_output, svm_input, model); % test the training data

%% plot 
day = 1;
range = (day-1)*24+1: day*24+24*10;
plot(predict_output(range));
hold on;
plot(expected_output(range));
legend('predict','real');

%%
figure ; scatter(svm_label, svm_inst(:,1));
figure ; scatter(svm_label, svm_inst(:,2));
% figure ; scatter(svm_label, svm_inst(:,3));
% figure ; scatter(svm_label, svm_inst(:,4));
% figure ; scatter(svm_label, svm_inst(:,5));
% figure ; scatter(svm_label, svm_inst(:,6));