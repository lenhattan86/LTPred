% % Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

GMT = [-6 -5 -6 -5 -6 -8 -5];

avg_color = 'red';
ar_color = 'blue';

IS_CLOSE = false;

fontAxis = 14;
fontTitle = 14;
fontLegend = 14;
LineWidth = 2;
FontSize = 14;

range = 1:7*24;

% method = 'rmse'; figPath = 'C:\Users\NhatTan\Dropbox\Papers\SoCC16\SharedManuscript\figs\'; yLabelText = 'RMSE'; yLimitVal = 220;
method = 'mae'; figPath = 'C:\Users\NhatTan\Dropbox\Papers\SoCC16\SharedManuscript\figs2\'; yLabelText = 'MAE'; yLimitVal = 150;

% figPath = '';

%% Load data
     
path_ar_solar_30 = 'google_dc/errors/AR/SOLAR/'; 
files_ar_solar_30 = [
         'AL_34.65_-86.783_2007_2009.csv_30 '; ...
         'GA_33.65_-84.433_2007_2009.csv_30 '; ...
         'IA_41.017_-94.367_2007_2009.csv_30'; ...
         'NC_35.733_-81.383_2007_2009.csv_30'; ...
         'OK_36.2_-95.883_2007_2009.csv_30  '; ...
         'OR_45.55_-122.4_2007_2009.csv_30  '; ...
         'SC_33.967_-80.467_2007_2009.csv_30']; 

path_ar_solar_24_30 = 'google_dc/errors/AR/SOLAR/'; 
files_ar_solar_24_30 = [
         'AL_34.65_-86.783_2007_2009.csv_24_30 '; ...
         'GA_33.65_-84.433_2007_2009.csv_24_30 '; ...
         'IA_41.017_-94.367_2007_2009.csv_24_30'; ...
         'NC_35.733_-81.383_2007_2009.csv_24_30'; ...
         'OK_36.2_-95.883_2007_2009.csv_24_30  '; ...
         'OR_45.55_-122.4_2007_2009.csv_24_30  ' ; ...
         'SC_33.967_-80.467_2007_2009.csv_24_30'];   
     
path_ar_solar_24_q_7_30_others = 'google_dc/errors/AR/SOLAR/'; 
files_ar_solar_24_q_7_30_others = [
         'CA_037.00_-120.00_2007_2009.csv_24_q_7_30'; ...
         'FL_027.77_-081.69_2007_2009.csv_24_q_7_30'; ...
         'ND_047.53_-099.78_2007_2009.csv_24_q_7_30'; ...
         'NE_041.13_-098.27_2007_2009.csv_24_q_7_30'; ...
         'NY_042.17_-074.95_2007_2009.csv_24_q_7_30'; ...
         'TX_031.05_-097.56_2007_2009.csv_24_q_7_30' ; ...
         'WA_047.40_-121.49_2007_2009.csv_24_q_7_30'];
     
path_avg_solar = 'google_dc/errors/AVG/SOLAR/'; 
files_avg_solar= [
         'AL_34.65_-86.783_2007_2009.csv '; ...
         'GA_33.65_-84.433_2007_2009.csv '; ...
         'IA_41.017_-94.367_2007_2009.csv'; ...
         'NC_35.733_-81.383_2007_2009.csv'; ...
         'OK_36.2_-95.883_2007_2009.csv  '; ...
         'OR_45.55_-122.4_2007_2009.csv  ' ; ...
         'SC_33.967_-80.467_2007_2009.csv'];

path_avg_solar_others = 'google_dc/errors/AVG/SOLAR/'; 
files_avg_solar_others= [
         'CA_037.00_-120.00_2007_2009.csv'; ...
         'FL_027.77_-081.69_2007_2009.csv'; ...
         'ND_047.53_-099.78_2007_2009.csv'; ...
         'NE_041.13_-098.27_2007_2009.csv'; ...
         'NY_042.17_-074.95_2007_2009.csv'; ...
         'TX_031.05_-097.56_2007_2009.csv' ; ...
         'WA_047.40_-121.49_2007_2009.csv'];   
     
path_svm_solar = 'google_dc/errors/SVM/SOLAR/'; 
files_svm_solar= [
         'CA_037.00_-120.00_2007_2009.csv'; ...
         'FL_027.77_-081.69_2007_2009.csv'; ...
         'ND_047.53_-099.78_2007_2009.csv'; ...
         'NE_041.13_-098.27_2007_2009.csv'; ...
         'NY_042.17_-074.95_2007_2009.csv'; ...
         'TX_031.05_-097.56_2007_2009.csv' ; ...
         'WA_047.40_-121.49_2007_2009.csv']; 

    
path_ar_wind_30 = 'google_dc/errors/AR/wind/'; 
files_ar_wind_30  = [
         'AL_34.65_-86.783_merge.csv_30 '; ...AL_34.65_-86.783_merge.csv_30
         'GA_33.65_-84.433_merge.csv_30 '; ...
         'IA_41.017_-94.367_merge.csv_30'; ...
         'NC_35.733_-81.383_merge.csv_30'; ...
         'OK_36.2_-95.883_merge.csv_30  '; ...
         'OR_45.55_-122.4_merge.csv_30  ' ; ...
         'SC_33.967_-80.467_merge.csv_30'];  

path_ar_wind_24_q_7_30_others = 'google_dc/errors/AR/WIND/';  
files_ar_wind_24_q_7_30_others = [
         'CA_037.00_-120.00_merge.csv_24_q_7_30'; ...
         'FL_027.77_-081.69_merge.csv_24_q_7_30'; ...
         'ND_047.53_-099.78_merge.csv_24_q_7_30'; ...
         'NE_041.13_-098.27_merge.csv_24_q_7_30'; ...
         'NY_042.17_-074.95_merge.csv_24_q_7_30'; ...
         'TX_031.05_-097.56_merge.csv_24_q_7_30' ; ...
         'WA_047.40_-121.49_merge.csv_24_q_7_30'];

path_avg_wind = 'google_dc/errors/AVG/WIND/'; 
files_avg_wind  = [
         'AL_34.65_-86.783_merge.csv '; ...AL_34.65_-86.783_merge.csv_30
         'GA_33.65_-84.433_merge.csv '; ...
         'IA_41.017_-94.367_merge.csv'; ...
         'NC_35.733_-81.383_merge.csv'; ...
         'OK_36.2_-95.883_merge.csv  '; ...
         'OR_45.55_-122.4_merge.csv  ' ; ...
         'SC_33.967_-80.467_merge.csv'];
     
path_avg_wind_others = 'google_dc/errors/AVG/WIND/';  
files_avg_wind_others = [
         'CA_037.00_-120.00_merge.csv'; ...
         'FL_027.77_-081.69_merge.csv'; ...
         'ND_047.53_-099.78_merge.csv'; ...
         'NE_041.13_-098.27_merge.csv'; ...
         'NY_042.17_-074.95_merge.csv'; ...
         'TX_031.05_-097.56_merge.csv' ; ...
         'WA_047.40_-121.49_merge.csv'];
     
path_svm_wind = 'google_dc/errors/SVM/WIND/';  
files_svm_wind = [
         'CA_037.00_-120.00_merge.csv'; ...
         'FL_027.77_-081.69_merge.csv'; ...
         'ND_047.53_-099.78_merge.csv'; ...
         'NE_041.13_-098.27_merge.csv'; ...
         'NY_042.17_-074.95_merge.csv'; ...
         'TX_031.05_-097.56_merge.csv' ; ...
         'WA_047.40_-121.49_merge.csv'];     
     

path_ar_price_30 = 'prices/errors/AR/'; 
files_ar_price_30  = [  'price_0029.76_-095.36_tx.houston.csv_30 ' ...
                      ; 'price_0037.34_-121.91_ca.np15.csv_30    ' ...
                      ; 'price_0039.66_-082.01_pjm.ohio.csv_30   ' ...
                      ; 'price_0039.94_-083.31_pjm.aep.csv_30    ' ...
                      ; 'price_0040.54_-074.40_pjm.nj.csv_30     ' ...
                      ; 'price_0040.75_-074.00_ny.nyc.csv_30     ' ...
                      ; 'price_0041.85_-087.63_pjm.chi.csv_30    ' ...
                      ; 'price_0042.36_-071.06_ne.bos.csv_30     ' ...
                      ];    
                  
path_ar_price_30 = 'prices/errors/AR/'; 
files_ar_price_30  = [  'price_0029.76_-095.36_tx.houston.csv_30 ' ...
                      ; 'price_0037.34_-121.91_ca.np15.csv_30    ' ...
                      ; 'price_0039.66_-082.01_pjm.ohio.csv_30   ' ...
                      ; 'price_0039.94_-083.31_pjm.aep.csv_30    ' ...
                      ; 'price_0040.54_-074.40_pjm.nj.csv_30     ' ...
                      ; 'price_0040.75_-074.00_ny.nyc.csv_30     ' ...
                      ; 'price_0041.85_-087.63_pjm.chi.csv_30    ' ...
                      ; 'price_0042.36_-071.06_ne.bos.csv_30     ' ...
                      ]; 
                  
path_ar_price_24_q_7_30 = 'prices/errors/AR/'; 
files_ar_price_24_q_7_30 =  ...
                  [ 'price_0029.76_-095.36_tx.houston.csv_24_q_7_30   ' ...
                  ; 'price_0037.34_-121.91_ca.np15.csv_24_q_7_30      ' ...
                  ; 'price_0039.66_-082.01_pjm.ohio.csv_24_q_7_30     ' ...
                  ; 'price_0044.96_-093.16_miso.minn.csv_24_q_7_30    ' ...
                  ; 'price_0040.54_-074.40_pjm.nj.csv_24_q_7_30       ' ...
                  ; 'price_0040.75_-074.00_ny.nyc.csv_24_q_7_30       ' ...
                  ; 'price_0041.85_-087.63_pjm.chi.csv_24_q_7_30      ' ...
%                   ; 'price_0042.36_-071.06_ne.bos.csv_24_q_7_30       ' ...
                  ];
path_avg_price = 'prices/errors/AVG/'; 
files_avg_price =  ...
                  [ 'price_0029.76_-095.36_tx.houston.csv' ...
                  ; 'price_0037.34_-121.91_ca.np15.csv   ' ...
                  ; 'price_0039.66_-082.01_pjm.ohio.csv  ' ...
                  ; 'price_0044.96_-093.16_miso.minn.csv ' ...
                  ; 'price_0040.54_-074.40_pjm.nj.csv    ' ...
                  ; 'price_0040.75_-074.00_ny.nyc.csv    ' ...
                  ; 'price_0041.85_-087.63_pjm.chi.csv   ' ...
%                   ; 'price_0042.36_-071.06_ne.bos.csv    ' ...
                  ];  
              
path_svm_price = 'prices/errors/SVM/'; 
files_svm_price =  ...
                  [ 'price_0029.76_-095.36_tx.houston.csv   ' ...
                  ; 'price_0037.34_-121.91_ca.np15.csv      ' ...
                  ; 'price_0039.66_-082.01_pjm.ohio.csv     ' ...
                  ; 'price_0044.96_-093.16_miso.minn.csv    ' ...
                  ; 'price_0040.54_-074.40_pjm.nj.csv       ' ...
                  ; 'price_0040.75_-074.00_ny.nyc.csv       ' ...
                  ; 'price_0041.85_-087.63_pjm.chi.csv      ' ...
%                   ; 'price_0042.36_-071.06_ne.bos.csv_24_q_7_30       ' ...
                  ];
     
% path_ar_workload_30 = 'workload/errors/AR/'; 
% files_ar_workload_30  = [
%          'AL_34.65_-86.783_merge.csv_30 '; ...AL_34.65_-86.783_merge.csv_30
%          'GA_33.65_-84.433_merge.csv_30 '; ...
%          'IA_41.017_-94.367_merge.csv_30'; ...
%          'NC_35.733_-81.383_merge.csv_30'; ...
%          'OK_36.2_-95.883_merge.csv_30  '; ...
%          'OR_45.55_-122.4_merge.csv_30  ' ; ...
%          'SC_33.967_-80.467_merge.csv_30']; 

path_ar_wind_24_30   = 'google_dc/errors/AR/WIND/'; 
files_ar_wind_24_30  = [
         'AL_34.65_-86.783_merge.csv_24_30 '; ...AL_34.65_-86.783_merge.csv_30
         'GA_33.65_-84.433_merge.csv_24_30 '; ...
         'IA_41.017_-94.367_merge.csv_24_30'; ...
         'NC_35.733_-81.383_merge.csv_24_30'; ...
         'OK_36.2_-95.883_merge.csv_24_30  '; ...
         'OR_45.55_-122.4_merge.csv_24_30  ' ; ...
         'SC_33.967_-80.467_merge.csv_24_30']; 

path_ar_workload = 'workload/errors/AR/'; 
files_ar_workload = [
         'AL_0034.77_-086.68_workload.csv_24_q_7_1'; ...
%          'GA_0033.72_-084.47_workload.csv_24_q_7_1'; ...
%          'IA_0041.58_-093.68_workload.csv_24_q_7_1'; ...
         'OK_0035.48_-097.50_workload.csv_24_q_7_1'; ...
         'OR_0044.81_-122.68_workload.csv_24_q_7_1'; ...
         'SC_0034.07_-081.19_workload.csv_24_q_7_1'; ...
%          'VA_0038.02_-078.57_workload.csv_24_q_7_1'; ...
         'TN_0036.07_-086.72_workload.csv_24_q_7_1'; ...
%          'AR_0034.57_-092.64_workload.csv_24_q_7_1'; ...
         'CA_0037.28_-120.45_workload.csv_24_q_7_1' ;...
         'NY_0041.59_-075.54_workload.csv_24_q_7_1' ;...
         ];
     
path_avg_workload = 'workload/errors/AVG/'; 
files_avg_workload = [
         'AL_0034.77_-086.68_workload.csv'; ...
%          'GA_0033.72_-084.47_workload.csv'; ...
%          'IA_0041.58_-093.68_workload.csv'; ...
         'OK_0035.48_-097.50_workload.csv'; ...
         'OR_0044.81_-122.68_workload.csv'; ...
         'SC_0034.07_-081.19_workload.csv'; ...         
%          'VA_0038.02_-078.57_workload.csv'; ...
         'TN_0036.07_-086.72_workload.csv'; ...
%          'AR_0034.57_-092.64_workload.csv'; ...
         'CA_0037.28_-120.45_workload.csv' ;...
         'NY_0041.59_-075.54_workload.csv' ;...
         ];
     
path_svm_workload = 'workload/errors/SVM/'; 
files_svm_workload = [
         'AL_0034.77_-086.68_workload.csv'; ...
%          'GA_0033.72_-084.47_workload.csv'; ...
%          'IA_0041.58_-093.68_workload.csv'; ...
         'OK_0035.48_-097.50_workload.csv'; ...
         'OR_0044.81_-122.68_workload.csv'; ...
         'SC_0034.07_-081.19_workload.csv'; ...         
%          'VA_0038.02_-078.57_workload.csv'; ...
         'TN_0036.07_-086.72_workload.csv'; ...
%          'AR_0034.57_-092.64_workload.csv'; ...
         'CA_0037.28_-120.45_workload.csv' ;...
         'NY_0041.59_-075.54_workload.csv' ;...
         ];

%% plot prediction errors of AR and AVG for solar
path1 = path_ar_solar_24_q_7_30_others; files1 =  files_ar_solar_24_q_7_30_others; 
path2 = path_avg_solar_others; files2 =  files_avg_solar_others;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
%xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='IA'; xlabels{4}='NC'; xlabels{5}='OK'; xlabels{6}='OR';    xlabels{7}='SC';  
xlabels{1}='CA'; xlabels{2}='FL'; xlabels{3}='ND'; xlabels{4}='NE'; xlabels{5}='NY'; xlabels{6}='TX';    xlabels{7}='WA';  

y = [];
for i=1:numOfFile
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);
    y = [y; rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;

l = cell(1,2);
l{1}='AR'; l{2}='L-AVG';  
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 
hold on;

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'ar_vs_avg_solar.eps']);

%% plot prediction errors of SVM, AR and AVG for solar
path0 = path_svm_solar; files0 =  files_svm_solar; 
path1 = path_ar_solar_24_q_7_30_others; files1 =  files_ar_solar_24_q_7_30_others; 
path2 = path_avg_solar_others; files2 =  files_avg_solar_others;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
% xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='IA'; xlabels{4}='NC'; xlabels{5}='OK'; xlabels{6}='OR';    xlabels{7}='SC';  
xlabels{1}='CA'; xlabels{2}='FL'; xlabels{3}='ND'; xlabels{4}='NE'; xlabels{5}='NY'; xlabels{6}='TX';    xlabels{7}='WA';  

y = [];
for i=1:numOfFile
    if exist(strcat(path0,files0(i,:),'.mat'), 'file')
        load(strcat(path0,files0(i,:),'.mat'));
        rmse_svm(i) = computeErrors(errors, expectedValues, method);
    else
        rmse_svm(i) = 0;
    end
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);
    y = [y; rmse_svm(i) rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;

l = cell(1,3);
l{1}='SVM'; l{2}='AR'; l{3}='L-AVG'; 
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 
hold on;

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'svm_vs_ar_vs_avg_solar.eps']);

%% debug
figure;
load(strcat(path0,files0(1,:),'.mat'));
plot(expectedValues(range));
hold on;
plot(predictedValues(range));
hold on;
load(strcat(path1,files1(1,:),'.mat'));
plot(predictedValues(range));
legend('real','SVM','AR');

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'predicted_solar.eps']);

%% plot prediction errors of AR and AVG for wind
path1 = path_ar_wind_24_q_7_30_others; files1 =  files_ar_wind_24_q_7_30_others; 
path2 = path_avg_wind_others; files2 =  files_avg_wind_others;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

%xlabels = cell(1,numOfFile);
%xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='IA'; xlabels{4}='NC'; xlabels{5}='OK'; xlabels{6}='OR';    xlabels{7}='SC';  

y = [];
for i=1:numOfFile
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);
    y = [y; rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;
l = cell(1,2);
l{1}='AR'; l{2}='L-AVG';  
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'ar_vs_avg_wind.eps']);

%% plot prediction errors of SVM, AR and AVG for wind
path0 = path_svm_wind; files0 =  files_svm_wind; 
path1 = path_ar_wind_24_q_7_30_others; files1 =  files_ar_wind_24_q_7_30_others; 
path2 = path_avg_wind_others; files2 =  files_avg_wind_others;

numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
% xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='IA'; xlabels{4}='NC'; xlabels{5}='OK'; xlabels{6}='OR';    xlabels{7}='SC';  
xlabels{1}='CA'; xlabels{2}='FL'; xlabels{3}='ND'; xlabels{4}='NE'; xlabels{5}='NY'; xlabels{6}='TX';    xlabels{7}='WA';  

y = [];
for i=1:numOfFile
    if exist(strcat(path0,files0(i,:),'.mat'), 'file')
        load(strcat(path0,files0(i,:),'.mat'));
        rmse_svm(i) = computeErrors(errors, expectedValues, method);
    else
        rmse_svm(i) = 0;
    end
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);
    y = [y; rmse_svm(i) rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;

l = cell(1,3);
l{1}='SVM'; l{2}='AR'; l{3}='L-AVG'; 
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 
hold on;

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'svm_vs_ar_vs_avg_wind.eps']);

%% debug
figure;
load(strcat(path0,files0(1,:),'.mat'));
plot(expectedValues(range));
hold on;
plot(predictedValues(range));
hold on;
load(strcat(path1,files1(1,:),'.mat'));
plot(predictedValues(range));
legend('real','SVM','AR');

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'predicted_wind.eps']);

%% plot prediction errors of AR and AVG for price
path1 = path_ar_price_24_q_7_30; files1 =  files_ar_price_24_q_7_30; 
path2 = path_avg_price; files2 =  files_avg_price;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
%xlabels{1}='houston'; xlabels{2}='np15'; xlabels{3}='ohio'; xlabels{4}='aep'; xlabels{5}='nj'; xlabels{6}='nyc';  xlabels{7}='chi';  xlabels{8}='bos';
xlabels{1}='TX'; xlabels{2}='CA'; xlabels{3}='OH'; xlabels{4}='MN'; 
xlabels{5}='NJ'; xlabels{6}='NY';  xlabels{7}='IL';  
%xlabels{8}='MA';

y = [];
for i=1:numOfFile
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);

    y = [y; rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;
l = cell(1,2);
l{1}='AR'; l{2}='L-AVG'; 
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'ar_vs_avg_price.eps']);

%% plot prediction errors of SVM & AR and AVG for price
path0 = path_svm_price; files0 =  files_svm_price;
path1 = path_ar_price_24_q_7_30; files1 =  files_ar_price_24_q_7_30; 
path2 = path_avg_price; files2 =  files_avg_price;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
%xlabels{1}='houston'; xlabels{2}='np15'; xlabels{3}='ohio'; xlabels{4}='aep'; xlabels{5}='nj'; xlabels{6}='nyc';  xlabels{7}='chi';  xlabels{8}='bos';
xlabels{1}='TX'; xlabels{2}='CA'; xlabels{3}='OH'; xlabels{4}='MN'; 
xlabels{5}='NJ'; xlabels{6}='NY';  xlabels{7}='IL';  
%xlabels{8}='MA';

y = [];
for i=1:numOfFile
    if exist(strcat(path0,files0(i,:),'.mat'), 'file')
        load(strcat(path0,files0(i,:),'.mat'));
        rmse_var(i) = computeErrors(errors, expectedValues, method);
    else
        rmse_var(i) = 0;
    end
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);

    y = [y; rmse_var(i) rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;
l = cell(1,3);
l{1}='SVM'; l{2}='AR'; l{3}='L-AVG'; 
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'svm_vs_ar_vs_avg_price.eps']);



%% debug
figure;
load(strcat(path0,files0(1,:),'.mat'));
plot(expectedValues(range));
hold on;
plot(predictedValues(range));
hold on;
load(strcat(path1,files1(1,:),'.mat'));
plot(predictedValues(range));
legend('real','SVM','AR');

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'predicted_prices.eps']);

%%
% Texas
figure;
[datetimeTemp,values] = importaPricefile('prices/sigcomm09-energydb/data/price_0029.76_-095.36_tx.houston.csv', 1, 365*3*24);
xlabel('hours'); ylabel('cents');
plot(values);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'electricity_prices_TX.eps']);
% OH
figure;
[datetimeTemp,values] = importaPricefile('prices/sigcomm09-energydb/data/price_0039.66_-082.01_pjm.ohio.csv', 1, 365*3*24);
plot(values);
xlabel('hours'); ylabel('cents');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'electricity_prices_OH.eps']);

% OH
figure;
[datetimeTemp,values] = importaPricefile('prices/sigcomm09-energydb/data/price_0040.54_-074.40_pjm.nj.csv', 1, 365*3*24);
plot(values);
xlabel('hours'); ylabel('cents');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'electricity_prices_NJ.eps']);

%% plot prediction errors of AR and AVG for workload
path1 = path_ar_workload; files1 =  files_ar_workload; 
path2 = path_avg_workload; files2 =  files_avg_workload;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
%xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='IA'; xlabels{4}='OK'; xlabels{5}='OR';    xlabels{6}='SC';  xlabels{7}='VA'; 
% xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='OK'; xlabels{4}='SC';  xlabels{5}='VA'; xlabels{6}='TN';  xlabels{7}='AR'; 
xlabels{1}='AL'; xlabels{2}='OK'; xlabels{3}='OR'; xlabels{4}='SC';  xlabels{5}='TN'; xlabels{6}='CA';  xlabels{7}='NY'; 

y = [];
for i=1:numOfFile
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);
    y = [y; rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;
l = cell(1,2);
l{1}='AR'; l{2}='L-AVG';  
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 
axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'ar_vs_avg_workload.eps']);

%% plot prediction errors of ANN & AR and AVG for workload
path0 = path_svm_workload; files0 =  files_svm_workload;
path1 = path_ar_workload; files1 =  files_ar_workload; 
path2 = path_avg_workload; files2 =  files_avg_workload;

files1Cell = cellstr(files1);
files2Cell = cellstr(files2);
numOfFile = length(files1(:,1));

xlabels = cell(1,numOfFile);
%xlabels{1}='AL'; xlabels{2}='GA'; xlabels{3}='IA'; xlabels{4}='OK'; xlabels{5}='OR';    xlabels{6}='SC';  xlabels{7}='VA'; 
xlabels{1}='AL'; xlabels{2}='OK'; xlabels{3}='OR'; xlabels{4}='SC';  xlabels{5}='TN'; xlabels{6}='CA';  xlabels{7}='NY'; 

y = [];
for i=1:numOfFile
    if exist(strcat(path0,files0(i,:),'.mat'), 'file')
        load(strcat(path0,files0(i,:),'.mat'));
        rmse_var(i) = computeErrors(errors, expectedValues, method);
    else
        rmse_var(i) = 0;
    end
    load(strcat(path1,files1(i,:),'.mat'));
    rmse_ar(i) = computeErrors(errors, expectedValues, method);
    load(strcat(path2,files2(i,:),'.mat'));
    rmse_avg(i) = computeErrors(errors, expectedValues, method);

    y = [y; rmse_var(i) rmse_ar(i) rmse_avg(i)];
end

figure1 = figure;
axes1 = axes('Parent',figure1);

h = bar(y);
h(1).FaceColor = ar_color;
h(2).FaceColor = avg_color;
l = cell(1,3);
l{1}='SVM'; l{2}='AR'; l{3}='L-AVG'; 
legend(h,l);
set(gca,'xticklabel', xlabels, 'fontsize',fontAxis) 

axis([0 8 0 yLimitVal]);
legend(h,l,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('location','FontSize',fontAxis);
ylabel([yLabelText ' (%)'],'FontSize',fontAxis);
print ('-depsc', [figPath 'svm_vs_ar_vs_avg_workload.eps']);

%% debug
figure;
load(strcat(path0,files0(1,:),'.mat'));
plot(expectedValues(range));
hold on;
plot(predictedValues(range));
hold on;
load(strcat(path1,files1(1,:),'.mat'));
plot(predictedValues(range));
legend('real','SVM','AR');

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
print ('-depsc', [figPath 'predicted_workload.eps']);
%%
if IS_CLOSE
    close all;
end