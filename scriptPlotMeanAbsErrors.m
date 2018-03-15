clear; close all; clc;

trainingPeriod = 9*30; %days
testPerido = 3*30; %days


type = 'wind';
if strcmp(type,'solar')
    %Solar PV/AL_PV_2006/Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv
    days            = [0 1        2       5       10      15      20      25      30];
    %one model
%     measAbsErrors =   [0 1.7502   1.8887  1.9036  1.9369  1.9678  1.9610     1.9677      2.0411];
%     stdErrors =  [0 3.6027   3.8613  3.8838  3.9028  3.9096  3.8182      3.7628     3.8587]; 
    % 24 models
    measAbsErrors =   [0 1.7502   1.8887  1.9036  1.9369  1.9678  1.9610     1.9677      2.0411];
    stdErrors =  [0 3.6027   3.8613  3.8838  3.9028  3.9096  3.8182      3.7628     3.8587]; 
elseif strcmp(type,'wind')
    days            =   [0 1          2           5           10          15          20          25          30];
    % one model
%     measAbsErrors =     [0 22.7450    23.4375     25.1037     27.4424     30.6276      34.3074    36.3008     38.8723];
%     stdErrors =         [0 34.7918    35.1301     35.2232     35.4404     35.7039      35.8488    36.1180     36.1997]; 
    % 24 models
    measAbsErrors =     [0 22.7450    23.4375     25.1037     27.4424     30.6276      34.3074    36.3008     38.8723];
    stdErrors =         [0 34.7918    35.1301     35.2232     35.4404     35.7039      35.8488    36.1180     36.1997]; 
elseif strcmp(type,'price')
    days            =   [0 1          2           5           10          15          20          25          30];
    measAbsErrors =     [0 22.7450    23.4375     25.1037     27.4424     30.6276      34.3074    36.3008     38.8723];
    stdErrors =         [0 34.7918    35.1301     35.2232     35.4404     35.7039      35.8488    36.1180     36.1997];     
elseif strcmp(type,'workload')
    days            =   [0 1          2           5           10          15          20          25          30];
    measAbsErrors =     [0 22.7450    23.4375     25.1037     27.4424     30.6276      34.3074    36.3008     38.8723];
    stdErrors =         [0 34.7918    35.1301     35.2232     35.4404     35.7039      35.8488    36.1180     36.1997];     
end


%% Plot    
figure;
plot(days, measAbsErrors,'-or'); 
hold on;
plot(days, stdErrors,'-->b'); 
xlabel('days');
ylim([0 max(max(measAbsErrors,stdErrors))+1]);
legend('Mean absolute error','Standard deviation');
grid on;
%%