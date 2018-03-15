clc; clear; close all;    
% Add class paths

addpath('functions');

m12Months = (31+28+31+30+31+30+31+31+30+31+30+31)*24;
m12MonthsPlus1 = (31+29+31+30+31+30+31+31+30+31+30+31)*24;
m3Months = (31+28+31)*24;
m5Months = (31+28+31+30+31)*24;
m1Month = 31*24;

duration = m1Month;

%% Load training data
INCLUDE_DATE = false;
trainWeatherFile = '..\renewable\noaa_weather\AL\csv\723235-13896-2006.gz.csv';
temp = cell2mat(importNWSData(trainWeatherFile, 2));
[C, rows, ic] = unique(temp(:,4:6),'rows');
temp = temp(rows,:);
temp(:,12) = filterNoise(temp(:,12),999.9);
temp(:,13) = filterNoise(temp(:,13),99999, [-inf 1000]);
temp(:,13) = filterNoise(temp(:,13),22000);
temp(:,14) = filterNoise(temp(:,14),999.9);
temp(:,15) = filterNoise(temp(:,15),999.9);
temp(:,16) = filterNoise(temp(:,16),9999.9,[-100 2000]);
if INCLUDE_DATE
    cols = [4:6 12:16];
    % cols = [4:5 12:16];
    %cols = [4 5 6 12 13]; % 13, 14, 15
    % cols = [4:6];
else
    cols = [12:16];
end
weatherData = temp(:,cols);

[LocalTime, PowerMW] = importPV('PV/AL_PV_2006/DA_34.05_-86.05_2006_DPV_36MW_60_Min.csv',2, 105121);
solarMW_avg = PowerMW;

%% Load Test data
testWeatherFile = '../renewable/noaa_weather/AL/csv/723235-13896-2006.gz.csv';
temp = cell2mat(importNWSData(testWeatherFile, 2));
[C, rows, ic] = unique(temp(:,4:6),'rows');
temp = temp(rows,:);
temp(:,12) = filterNoise(temp(:,12),999.9);
temp(:,13) = filterNoise(temp(:,13),9999.9, [-inf 1000]);
temp(:,14) = filterNoise(temp(:,14),999.9);
temp(:,15) = filterNoise(temp(:,15),999.9);
temp(:,16) = filterNoise(temp(:,16),9999.9, [-100 2000]);
temp(temp(:,13)==22000,13) = 0; 
testWeatherData = temp(:,cols);

[LocalTime, PowerMW] = importPV('PV/AL_PV_2006/Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv',2, 105121);
% Averaging data
T_avg = 12;
dataLen = length(PowerMW);
testSolarMW_avg = mean(reshape(PowerMW,[T_avg,dataLen/T_avg]));
testSolarMW_avg = testSolarMW_avg';

%% load wunderground data

AL34 = importWunderground('../weather/data/AL_34.05_-86.05_wunderground.csv', 4);
temperatureF = AL34(:,2);
temperatureF = AL34(1:floor(length(AL34(:,2))/3)*3,2);
temperatureF = mean(reshape(temperatureF,[3,length(temperatureF)/3]));
temperatureF = filterNoise(temperatureF,-9999, [-200 200]);
temperatureF = temperatureF(1:duration);


%% run SVM
trainDuration = 1:duration;
testDuration = 1:duration;
%testSolarMW_avg = solarMW_avg;

svm_label = testSolarMW_avg(trainDuration);
svm_inst = weatherData(trainDuration,:);

%plot(svm_inst(:,1));
%%
scatter(svm_label, temperatureF);