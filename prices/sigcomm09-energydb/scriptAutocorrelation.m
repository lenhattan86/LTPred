%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');
addpath('../../functions');

titleName = 'Electricity prices';
xLabel = 'Days';
yLabel = 'Autocorrelation';

%% Load data
path = 'data/'; 
file = 'price_37.34_-121.91_ca.np15.csv';

filePath = strcat(path,file);
figureName = strcat('fig/','price_autocorr');
[LocalTime, prices] = importPrices(filePath);
% Averaging data

lags = [0:24:60*24]';
%% plot    
figure;
autocorr = acf_adv(prices, lags);
stem(0:length(lags)-1,autocorr,'b');
title(titleName)
xlabel(xLabel); ylabel(yLabel);
print(figureName,'-deps');