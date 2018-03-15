%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

%% Load data
%solar
save_folder = 'google_dc/errors/';
path = 'google_dc/PV/AL_PV_2006/'; file = 'Actual_34.05_-86.05_2006_DPV_36MW_5_Min'; 
%path = 'google_dc/PV/GA_PV_2006/'; file = 'Actual_33.25_-84.25_2006_DPV_21MW_5_Min';
%path = 'google_dc/PV/IA_PV_2006/'; file = 'Actual_41.15_-94.85_2006_UPV_38MW_5_Min';
%path = 'google_dc/PV/NC_PV_2006/'; file = 'Actual_35.15_-81.15_2006_DPV_34MW_5_Min';
%path = 'google_dc/PV/OK_PV_2006/'; file = 'Actual_36.05_-95.45_2006_UPV_80MW_5_Min';
%path = 'google_dc/PV/OR_PV_2006/'; file = 'Actual_45.35_-122.35_2006_UPV_20MW_5_Min';
%path = 'google_dc/PV/SC_PV_2009/'; file = 'Actual_33.05_-80.25_2006_UPV_128MW_5_Min';

% prices

[LocalTime, PowerMW] = importPV(strcat(path , file ,'.csv'),2, 105121);
%%
% Averaging data
T_avg = 12;
dataLen = length(PowerMW);
PowerMW_avg = mean(reshape(PowerMW,[T_avg,dataLen/T_avg]));
PowerMW_avg = PowerMW_avg';
%plot(PowerMW_avg)

% common prediction parameters
% past = 72 hours (3 days).
pastSteps = 3*24*60/(5*T_avg);
% future = 1 hour
futureSteps = 1*60/(5*T_avg);
% training duration 90 days
trainingDuration = 90*24*60/(5*T_avg);
trainingData = PowerMW_avg(1:trainingDuration);
% Test duration 30 days
testDuration = 30*24*60/(5*T_avg); % 
testInputData = PowerMW_avg(1:trainingDuration+testDuration-1);
expectedValues = PowerMW_avg(trainingDuration+1:trainingDuration+testDuration);


%% Basic Prediction methods
% AR + get rid of negative values.
% prediction parameters
K = futureSteps; % K ahead steps.
TR = (31+28)*24*60/(5*T_avg); % training window    
n = pastSteps; % number of parameters in AR

% training
data = iddata(trainingData,[]);
sys = ar(data, n);

% Using sliding window predict~
% test model
predictedValues = zeros(1, testDuration);
for t = 1: testDuration    
    inputData = iddata(testInputData(t:t+trainingDuration-1),[]);
    predict_ts = forecast(sys,inputData,K);
    predictedValues(t) = predict_ts.y;    
end
%predictedValues = max(predictedValues,0);
%% Analysis
errors = predictedValues - expectedValues';
meanError = mean(errors);

%% plot    
figure;
plot(expectedValues,'b'); 
hold on;
plot(predictedValues,'r');
legend('Real', 'predicted');
title('Autoregressive (AR)');

figure;
autocorr = acf(errors, 24);
plot(autocorr,'b');
title('Autocorrelation of Autoregressive (AR)');

figure;
plot(errors,'r'); 
legend('Prediction errors');
title('Autoregressive (AR) errors');

figure;
cdfplot(errors);
title('cdf of AR Errors');

%% Save data
Lat = str2double(file(8:12)); 
Lon = str2double(file(14:19)); 
save(strcat(save_folder, file, '.mat'),'Lon','Lat','errors', 'expectedValues', 'predictedValues');