clear; clc; close all;
% Add class paths
addpath('functions');
%% Load data
path = 'PV/AL_PV_2006/'; 
file = 'Actual_34.05_-86.05_2006_DPV_36MW_5_Min.csv';

filePath = strcat(path,file);
figureName = strcat('fig/','solar_autocorr');
[LocalTime, PowerMW] = importPV(filePath,2,105121);
% Averaging data
T_avg = 12;
dataLen = length(PowerMW);
avgLen = dataLen/T_avg;
PowerMW_avg = mean(reshape(PowerMW,[T_avg,avgLen]));
PowerMW_avg = reshape(PowerMW_avg,[avgLen 1]);
%% plot    

Fs = 1;            % Sampling frequency
T = 1/Fs;                 % Sampling period
L = avgLen;               % Length of signal
xLen = 150;
t = (0:L-1)*T; 
Y = fft(PowerMW_avg);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
%f = Fs*(0:(L/2))/L;
f = T*(0:(L/2))/L;
%f = f(1:xLen); P1= P1(1:xLen)
time = (1/24)*t(1:L/2);
bar(time,P1(1:L/2))
%plot(f,P1)
title('Periodogram')
xlabel('Hours')
ylabel('Value')