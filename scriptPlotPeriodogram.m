clear; clc; close all;
% Add class paths
addpath('functions');

fontAxis = 14;
fontTitle = 14;
fontLegend = 14;
LineWidth = 2;
FontSize = 14;

% dataType = 'solar';
% dataType = 'wind'; 
% dataType = 'price'; 
dataType = 'workload';
% figPath = 'C:\Users\NhatTan\Dropbox\Research-Tan\SharedManuscript\figs\';
figPath = 'C:\Users\NhatTan\Dropbox\Papers\SoCC16\SharedManuscript\figs\';
% figPath = '';
%% Load data
if strcmp(dataType,'solar')
    load 'google_dc/periodogram/SOLAR/AL_34.65_-86.783_2007_2009.csv.mat';
elseif strcmp(dataType,'wind')
    load 'google_dc/periodogram/WIND/AL_34.65_-86.783_merge.csv.mat';
elseif strcmp(dataType,'price')
    load 'prices/sigcomm09-energydb/periodogram/price_37.34_-121.91_ca.np15.csv.mat';
elseif strcmp(dataType,'workload')
    load 'workload/errors/AL_0034.77_-086.68_workload.csv.mat';
end

figure1 = figure;
axes1 = axes('Parent',figure1);

plot(1./freq, value, 'linewidth',LineWidth);
xlim([0 75]);
%title('Periodogram for PV Generation')
%title('Periodogram for Wind Generation')
%title('Periodogram for Prices')
%title('Periodogram for Workload')
set(gca, 'XTick',[0 24 50 75],'fontsize',fontAxis);
% set(axes1,'FontSize',fontAxis);
% axis([1 10 0 3.2]);
% legend(legendStr,'Location','northeast','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('hours','FontSize',fontAxis);
ylabel('periodogram','FontSize',fontAxis)
print ('-depsc', [figPath dataType '_periodogram.eps']);
