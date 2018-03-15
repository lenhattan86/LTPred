%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

%% Load data
%ar
% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783.csv_1.mat';
% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783.csv_30.mat';

% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_1.mat'; 
% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_30.mat';
% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_24_30.mat';
path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_24_q_7_30.mat';


% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_30.t.mat';
% path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_60.t.mat'

% path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783.csv_1.mat';
% path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783.csv_30.mat';

% path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783_merge.csv_30.mat';

% path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783_merge.csv_1.t.mat';
% path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783_merge.csv_30.t.mat';


% path = 'prices/sigcomm09-energydb/errors/AR/'; file = 'price_37.34_-121.91_ca.np15.csv_1.mat';
% path = 'prices/sigcomm09-energydb/errors/AR/'; file = 'price_37.34_-121.91_ca.np15.csv_30.mat';

%ar_adv
% path = 'google_dc/errors/AR_ADV/SOLAR/'; file = 'AL_34.65_-86.783.csv.mat';
% path = 'google_dc/errors/AR_ADV/WIND/'; file = 'AL_34.65_-86.783.csv.mat';
% path = 'prices/sigcomm09-energydb/errors/'; file = 'AR_advprice_37.34_-121.91_ca.np15.csv.mat';

%svm
% path = 'google_dc/errors/SVM/SOLAR/'; file = 'AL_34.65_-86.783_SOLAR.mat';
% path = 'google_dc/errors/SVM/WIND/'; file = 'AL_34.65_-86.783_WIND.mat';

%avg
% path = 'google_dc/errors/AVG/SOLAR/'; file = 'AL_34.65_-86.783.csv.mat';
% path = 'google_dc/errors/AVG/WIND/'; file =  'AL_34.65_-86.783.csv.mat';
% path = 'google_dc/errors/AVG/PRICE/'; file = 'price_37.34_-121.91_ca.np15.csv.mat';
day = 24;
load(strcat(path , file));

%% Analysis

errors =  expectedValues - predictedValues;
meanError = mean(errors)
meanAbsError = mean(abs(errors))
standadDeviationError = std(errors)
len = length(predictedValues);

startDay = 2;
days = (1:len)/day;
xRange = (startDay:(startDay+6)*day);

%nameOfMethods = strcat(num2str(futureSteps/day), ' day ahead');

%% plot    
figure;
plot(days(xRange), expectedValues(xRange),'b'); 
hold on;
plot(days(xRange), max(predictedValues(xRange),0),'r');
% hold on;
% plot(upperboundValues,'m');
% hold on;
% plot(lowerboundValues,'g');
legend('Real', 'predicted');
xlabel('days'); ylabel('Power');
%title(nameOfMethods);

figure;
autocorr = acf(errors, 23);
stem(autocorr,'b');
title('Autocorrelation')

figure;
plot(errors,'r'); 
legend('Prediction errors');
title('Autoregressive (AR) errors');

figure;
cdfplot(errors);
title('cdf of AR Errors');
%%
figure;
h = histogram(errors,'Normalization','probability')
title('Probability Density of Errors');
plot(h.BinEdges(1:h.NumBins)+h.BinWidth/2, h.Values)
% x = [-2.5:.1:2.5]; 
% norm = normpdf(x,0,1.2);
% plot(x,norm);
%%
%[D, PD] = allfitdist(errors, 'PDF');
%%
% figure
% ksdensity(errors)
%%
%[D, PD] = allfitdist(errors, 'CDF') ;