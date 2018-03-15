%% find the best q for AR by somparing mean squared errors for each q
% Reset
clc; clear; close all;
% Add class paths

q = [1,2,3,4,5,6,7,8,9,10,30,60,120];
qLen = length(q);
absoluteMeanArray = zeros(qLen,1);
squareErrorArray = zeros(qLen,1);


%% load data
% @todo
% path = 'google_dc/errors/AR/SOLAR/';
% files = cellstr([   'SC_33.967_-80.467_2007_2009.csv_24_q_1_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_2_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_3_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_4_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_5_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_6_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_7_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_8_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_9_30.mat  ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_10_30.mat ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_30_30.mat ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_60_30.mat ' ...
%                   ; 'SC_33.967_-80.467_2007_2009.csv_24_q_120_30.mat' ...
%                   ]);

% path = 'google_dc/errors/AR/WIND/';
% files = cellstr([  'AL_34.65_-86.783_merge.csv_24_q_1_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_2_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_3_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_4_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_5_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_6_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_7_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_8_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_9_30.mat  ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_10_30.mat ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_30_30.mat ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_60_30.mat ' ...
%                 ; 'AL_34.65_-86.783_merge.csv_24_q_120_30.mat' ...
%                 ]);

% path = 'prices/errors/AR/';
% files = cellstr([  'price_0037.34_-121.91_ca.np15.csv_24_q_1_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_2_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_3_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_4_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_5_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_6_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_7_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_8_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_9_30.mat  ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_10_30.mat ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_30_30.mat ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_60_30.mat ' ...
%                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_120_30.mat' ...
%                  ]);

path = 'workload/errors/AR/';
files = cellstr([  'AL_0034.77_-086.68_workload.csv_24_q_1_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_2_1.mat ' ...                 
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_3_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_4_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_5_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_6_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_7_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_8_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_9_1.mat ' ...
                 ; 'AL_0034.77_-086.68_workload.csv_24_q_10_1.mat' ...
                 ]);
               
qLen = min(length(q), length(files));
for i =1:qLen
    load([path,files{i}]);
    absoluteMeanArray(i) = mean(abs(errors));
    squareErrorArray(i) = sqrt(mean(errors.^2));
end
    
%% plot
figure;
% plot(q,absoluteMeanArray);
% hold on;
plot(q(1:qLen),squareErrorArray(1:qLen));
legend('RMSE');
axis([1 inf 0 inf])
grid on;

