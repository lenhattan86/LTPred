%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');


xLabel = 'Days';
yLabel = 'Autocorrelation';

%% Load data
% path = 'google_dc/PV/AL_PV_2006/'; 
% file = 'Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv';
% filePath = strcat(path,file);
% [LocalTime, PowerMW] = importPV(filePath,2,105121);
% figureName = strcat('fig/','solar_autocorr');
% % Averaging data
% T_avg = 12;
% dataLen = length(PowerMW);
% avgLen = dataLen/T_avg;
% values = mean(reshape(PowerMW,[T_avg,avgLen]));
% values = reshape(values,[avgLen 1]);
%% Solar
% titleName = 'PV';
% path = 'google_dc/NREL_SAM/SOLAR/'; 
% file = 'AL_34.65_-86.783.csv';
% filePath = strcat(path,file);
% [Datetimes,AmbienttemperatureC,ACinverterpowerW,Angleofincidencedeg,BeamirradianceWm2,DCarraypowerW,DiffuseirradianceWm2,GlobalhorizontalirradianceWm2,ModuletemperatureC,PlaneofarrayirradianceWm2,PowergeneratedbysystemkW,Shadingfactorforbeamradiation,Sunupoverhorizon01,TransmittedplaneofarrayirradianceWm2,Windspeedms] = ...
%     importSAMSolar(filePath)
% values = PowergeneratedbysystemkW;
%% Wind
titleName = 'Wind Autocorrelation';
path = 'google_dc/NREL_SAM/WIND/'; 
file = 'AL_34.65_-86.783.csv';
filePath = strcat(path,file);
[DateTimes,AirtemperatureC,PowergeneratedbysystemkW1,Pressureatm,Winddirectiondeg,Windspeedms1] ...
    = importSAMWind(filePath);
values = PowergeneratedbysystemkW1;
%% Price
% titleName = 'Price Autocorrelation';
% path = 'prices/sigcomm09-energydb/data/'; 
% file = 'price_37.34_-121.91_ca.np15.csv';
% filePath = strcat(path, file);
% [datetimes,prices] = importPrices(filePath);
% values = prices;

%% lag
fs = 24;
lags = [0:fs:120*fs]';
%% plot    
figure;
autocorr = acf_adv(values, lags);
stem(0:length(lags)-1,autocorr,'b');
%title(titleName)
xlabel(xLabel); ylabel(yLabel);
% print(figureName,'-deps');