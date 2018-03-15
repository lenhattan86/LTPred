%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');
RUN_AR      = 0;
RUN_ANN     = 1;

%% Load data
[LocalTime, PowerMW] = importPV('PV/AL_PV_2006/Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv',2, 105121);
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
% future = 1 day
futureSteps = 24*60/(5*T_avg);
% training duration 90 days
trainingDuration = 90*24*60/(5*T_avg);
trainingData = PowerMW_avg(1:trainingDuration);

%% Basic Prediction methods
% AR + get rid of negative values.
if RUN_AR
    % prediction parameters
    K = futureSteps; % K ahead steps.
    TR = (31+28)*24*60/(5*T_avg); % training window    
    n = pastSteps; % number of parameters in AR
    % training
    data = iddata(trainingData,[]);
    
    sys = ar(data, n);
    % test model
    predict_ts = forecast(sys,data,K);
    predict_ar = max(predict_ts.y,0);  
    
    figure;
    plot(PowerMW_avg(TR+1:TR+K),'b'); 
    hold on;
    plot(predict_ar,'r');
    legend('Real', 'predicted');
    title('Autoregressive (AR)');
end

%% Advanced Neural Network
if RUN_ANN
    % prediction parameters

    % ANN application function 
    TS = 30*24*60/(5*T_avg);
    Delay = 72;
    K = 24*60/(5*T_avg);   
    
    x1  = PowerMW_avg(Delay+1:Delay+TS)';
    xi1 = PowerMW_avg(1:Delay)';
    [y1,xf1] = ann_ntstool(x1,xi1);
    
%     pastData = PowerMW_avg(1:Delay+1);
%     y_da = da_ann_predict(pastData, Delay, K);
%     x_da = PowerMW_avg(Delay+1:Delay+K);
    % test
%     figure;
%     plot(x_da,'b'); 
%     hold on;
%     plot(y_da,'r');
%     legend('Real', 'predicted');
%     title('Nonlinear Autoregressive (NAR) Neural Network');
end

%% Result plot & save