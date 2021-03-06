%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

errorLineStyle = '--';
predictedTimeLineStyle = '-.';
 
days = [1 5 10 15 20 25 30 35 40 45 50 55 60 65]; 
dayLen = length(days);
errorVarArray = 5*ones(dayLen,1);
predictedVarArray = 10*ones(dayLen,1);
%% Load data
%ar
% path = 'google_dc/errors/AR/SOLAR/';
% files = cellstr([   'AL_34.65_-86.783_2007_2009.csv_1.mat ' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_5.mat ' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_10.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_15.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_20.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_25.mat' ...
%                   ; 'AL_34.65_-88.783_2007_2009.csv_30.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_35.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_40.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_45.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_50.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_55.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_60.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_65.mat' ...
%                   ]);


% path = 'google_dc/errors/AR/SOLAR/';
% files = cellstr([   'AL_34.65_-86.783_2007_2009.csv_24_1.mat ' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_5.mat ' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_10.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_15.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_20.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_25.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_30.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_35.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_40.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_45.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_50.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_55.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_60.mat' ...
%                   ; 'AL_34.65_-86.783_2007_2009.csv_24_65.mat' ...
%                   ]);

path = 'google_dc/errors/AR/SOLAR/';
files = cellstr([   'AL_34.65_-86.783_2007_2009.csv_24_q_7_1.mat ' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_5.mat ' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_10.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_15.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_20.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_25.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_30.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_35.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_40.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_45.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_50.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_55.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_60.mat' ...
                  ; 'AL_34.65_-86.783_2007_2009.csv_24_q_7_65.mat' ...
                  ]);
              
% path = 'google_dc/errors/AR/WIND/';
% files = cellstr([   'AL_34.65_-86.783_merge.csv_1.mat ' ...
%                   ; 'AL_34.65_-86.783_merge.csv_5.mat ' ...
%                   ; 'AL_34.65_-86.783_merge.csv_10.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_15.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_20.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_25.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_30.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_35.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_40.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_45.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_50.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_55.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_60.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_65.mat' ...
%                   ]);  

% path = 'google_dc/errors/AR/WIND/';
% files = cellstr([   'AL_34.65_-86.783_merge.csv_24_1.mat ' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_5.mat ' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_10.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_15.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_20.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_25.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_30.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_35.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_40.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_45.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_50.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_55.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_60.mat' ...
%                   ; 'AL_34.65_-86.783_merge.csv_24_65.mat' ...
%                   ]);  

path = 'google_dc/errors/AR/WIND/';
files = cellstr([   'AL_34.65_-86.783_merge.csv_24_q_7_1.mat ' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_5.mat ' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_10.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_15.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_20.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_25.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_30.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_35.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_40.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_45.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_50.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_55.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_60.mat' ...
                  ; 'AL_34.65_-86.783_merge.csv_24_q_7_65.mat' ...
                  ]);  

% path = 'prices/errors/AR/';
% files = cellstr([       'price_0029.76_-095.36_tx.houston.csv_1.mat ' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_5.mat ' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_10.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_15.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_20.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_25.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_30.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_35.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_40.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_45.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_50.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_55.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_60.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_65.mat' ...
%                       ]); 
                  
% path = 'prices/errors/AR/';
% files = cellstr([       'price_0029.76_-095.36_tx.houston.csv_24_1.mat ' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_5.mat ' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_10.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_15.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_20.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_25.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_30.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_35.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_40.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_45.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_50.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_55.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_60.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_65.mat' ...
%                       ]);     
                  
% path = 'prices/errors/AR/';
% files = cellstr([       'price_0029.76_-095.36_tx.houston.csv_24_q_7_1.mat ' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_5.mat ' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_10.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_15.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_20.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_25.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_30.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_35.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_40.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_45.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_50.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_55.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_60.mat' ...
%                       ; 'price_0029.76_-095.36_tx.houston.csv_24_q_7_65.mat' ...
%                       ]);     
day = 24;              
hour = 12
for i = 1:dayLen
    load([path files{i}]);
%     errorVarArray(i) = var(errors);
%     predictedVarArray(i) = var(predictedValues);
%     normErrors = 100.*errors(hour:day:length(errors)/day) / mean(expectedValues(hour:day:length(errors)/day)); % percentage of errors
    normErrors = 100.*errors./mean(expectedValues);
    errorVarArray(i) = std(normErrors);
    %predictedVarArray(i) = std(predictedValues)/mean(expectedValues)*100;
    rmseArray(i) = sqrt(mean(normErrors.^2));    
end


%% plot    
figure;
[hAx, hLine1, hLine2] = plotyy(days, errorVarArray, days, rmseArray); 
set(hLine1,'LineStyle', errorLineStyle, 'marker','o', 'LineWidth', 2)
set(hLine2,'LineStyle', predictedTimeLineStyle,'marker','x', 'LineWidth', 2)
xlabel('Days ahead');
ylabel(hAx(1), 'Standard Deviation of prediction errors') % left y-axis
axis(hAx(1), [0      max(days)          0         max(errorVarArray)+ 1]);
% axis(hAx(1), [0      max(days)          0          30]);
ylabel(hAx(2), 'RMSE of prediction errors') % right y-axis
axis(hAx(2), [0      max(days)          0        max(rmseArray)+ 1])
% axis(hAx(2), [0      max(days)          0          30])
%title('Trade-off between charging cost and waiting time');
grid on;

figure;
plot(days, errorVarArray, 'LineStyle', errorLineStyle, 'marker','o', 'LineWidth', 2);
hold on;
plot(days, rmseArray, predictedTimeLineStyle,'marker','x', 'LineWidth', 2);
legend('STD of prediction errors', 'RMSE of prediction errors');
axis([0      max(days)          0         inf]);
grid on;

figure;
plot(expectedValues);
hold on;
plot(predictedValues);
grid on;