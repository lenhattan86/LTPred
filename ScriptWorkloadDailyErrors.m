%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

%% Load data
path = 'workload/errors/AR/'; file = 'AL_0034.77_-086.68_workload.csv_24_q_7_1.mat';
% path = 'workload/errors/AR/'; file = 'GA_0033.72_-084.47_workload.csv_24_q_7_1.mat';

load(strcat(path , file));
%% distribution of errors in a day
% errs = expectedValues - predictedValues;
day = 24;
numOfDay = length(errors)/day;
hours = 6;
values = reshape(errors(1:numOfDay*day),[day numOfDay]);
for iDay = 1:hours:day
    figure(1)
    valTemp = reshape(values(iDay:iDay+hours-1,:),[1 hours*numOfDay]);
    h = histogram(valTemp,'Normalization','probability','DisplayStyle','stairs'); 
    figure(2)
    yPlot   = h.BinEdges(1:h.NumBins)+h.BinWidth/2; 
    xPlot   = h.Values;
    plot(yPlot,xPlot);
    hold on;
end
legend('1-6','7-12','13-18','19-24');
grid on;