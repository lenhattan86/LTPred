%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

dataType = 'solar'; hours = 3;
% dataType = 'wind'; hours = 6;
% dataType = 'price'; hours = 6;
% dataType = 'workload'; hours = 6;
% hours = 1;
isFit = 0;
%% Load data

xCutOff = 200;
if strcmp(dataType,'solar')
    %ar
    % path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783.csv_30.mat';
    % path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_30.mat';
    % path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_24_30.mat';
    path = 'google_dc/errors/AR/SOLAR/'; file = 'AL_34.65_-86.783_2007_2009.csv_24_q_7_30.mat';
%     path = 'google_dc/errors/AR/SOLAR/'; file = 'WA_047.40_-121.49_2007_2009.csv_24_q_7_30.mat';
    xRange = 250;    
elseif strcmp(dataType,'wind')
    % path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783.csv_30.mat';
%     path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783_merge.csv_30.mat';
%     path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783_merge.csv_24_30.mat';
    path = 'google_dc/errors/AR/WIND/'; file = 'AL_34.65_-86.783_merge.csv_24_q_7_30.mat';
    xRange = 200;
elseif strcmp(dataType,'price')
    path = 'prices/errors/AR/'; file = 'price_0037.34_-121.91_ca.np15.csv_24_q_7_30.mat';
    % path = 'prices/errors/AR/'; file = 'price_0029.76_-095.36_tx.houston.csv_24_30.mat';
%     path = 'prices/errors/AR/'; file = 'price_0029.76_-095.36_tx.houston.csv_24_q_7_30.mat';
    xRange = 200;
elseif strcmp(dataType,'workload')    
    path = 'workload/errors/AR/'; file = 'AL_0034.77_-086.68_workload.csv_24_q_7_1.mat';
    xRange = 150;
end
%avg
% path = 'google_dc/errors/AVG/SOLAR/'; file = 'AL_34.65_-86.783.csv.mat';
% path = 'google_dc/errors/AVG/WIND/'; file =  'AL_34.65_-86.783.csv.mat';
%path = 'google_dc/errors/AVG/PRICE/'; file = 'price_37.34_-121.91_ca.np15.csv.mat';

load(strcat(path , file));
if ~strcmp(dataType,'price')
    predictedValues = abs(predictedValues);
end
% errors = expectedValues - predictedValues;
% errors = errors./mean(expectedValues)*100;


%% distribution of errors in a day
if strcmp(dataType,'workload')    
    year = length(errors)/day;
else
    year = 365;
end

values = reshape(errors(1:year*day),[day year]);
expVals = reshape(expectedValues(1:year*day),[day year]);
for i=1:day
    values(i,:) = values(i,:)/mean(expVals(i,:))*100;
end
if strcmp(dataType,'solar')    
    hourStart = 7;
    hourEnd = 18;
else
    hourStart = 1;
    hourEnd = 24;   
end
i = 1;
for iDay = hourStart:hours:hourEnd
    legendStr{i} = num2str(iDay);
%     valTemp = reshape(values(iDay:iDay+hours-1,:),[1 hours*year]);    
    valTemp = values(iDay,:); 
    valTemp = valTemp - mean(valTemp);
    valTemp = valTemp(valTemp>-xRange);
    valTemp = valTemp(valTemp<xRange);
    std(valTemp)
    figure(1)
%         distname = 'generalized extreme value';
    distname = 'tlocationscale';
    [f,xf] = ksdensity(valTemp);
    plot(xf,f);
    hold on;
    if isFit   
        legendStr{i} = [num2str(iDay) ' ' num2str(iDay) ' fit'];
        PD = fitdist(valTemp', distname); data = valTemp;
%         PD = fitdist(f, distname); 
%         data = f;        
        nbins = max(min(length(data)./10,100),100);
        xi = linspace(min(data),max(data),nbins);
        dx = mean(diff(xi));
        xi2 = linspace(min(data),max(data),nbins*10)';
        fi = histc(data,xi-dx);
        fi = fi./sum(fi)./dx;
        ys = pdf(PD,xi2);
        if ~strcmp(dataType,'solar') || (iDay > 6 && iDay < 19)
            plot(xi2,ys,'LineWidth',2)
            hold on;
        end
        %     [D, PD] = allfitdist(valTemp, 'PDF');        
    end    
    
    valTemp = valTemp(valTemp>-xCutOff);
    valTemp = valTemp(valTemp<xCutOff);    
    [probabilities,xf] = ksdensity(valTemp);  
    probabilities = probabilities(xf>-xCutOff);
    xf = xf(xf>-xCutOff); 
%     xf = [-100 xf];    probabilities = [0 probabilities];
%     plot(xf,probabilities);
    save(['probabilities/' dataType '/probability_' int2str(iDay) '.mat'],'probabilities', 'xf');
%     [D, PD] = allfitdist(valTemp, 'PDF');
    
    i = i + 1;
end

xlabel('Value');
ylabel('Probability Density');
title('Probability Density Function');
legend(legendStr);
grid on;
axis([-xRange xRange 0 inf]) 

%% Analysis
if strcmp(dataType,'workload')      
else
    len = length(predictedValues);
    errors =  expectedValues - predictedValues;
    % numOfMonths = 12; numOfDays = 30;
    numOfMonths = 4; numOfDays = 90;
    day = 24;

    values = reshape(errors(1:numOfDays*numOfMonths*day),[day numOfDays numOfMonths]);
    monthlyErrors = zeros(numOfMonths, day);
    for iMonth = 1:numOfMonths
        monthlyErrors(iMonth,:) = mean(values(:,:,iMonth),2);
    end
    dailyErrors = mean(monthlyErrors);

    figure
    plot(monthlyErrors');
    % hold on;
    % plot(dailyErrors);
    % legend('Jan','Feb','Mar','April','May','June','July','Aug','Sep','Oct','Nov','Dec');
    legend('Jan-Mar','April-June','July-Sep','Oct-Dec');
end


