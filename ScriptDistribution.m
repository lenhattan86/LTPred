%% Prediction methods & Prediction Errors
% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

% dataType = 'solar'; hours = 3;
% dataType = 'wind'; hours = 6;
dataType = 'price'; hours = 6;
% dataType = 'workload'; hours = 6;
% hours = 1;
isFit = 0;
RANGE = 500;

isSAVE = 0;

fontAxis = 14;
fontTitle = 14;
fontLegend = 14;
LineWidth = 2;
FontSize = 14;
%% Load data

% figPath = 'C:\Users\NhatTan\Dropbox\Research-Tan\SharedManuscript\figs\';
figPath = 'figs\';

if strcmp(dataType,'solar')
    %ar
    path = 'google_dc/errors/AR/SOLAR/'; 
    files = [
             'AL_34.65_-86.783_2007_2009.csv_24_q_7_30 '; ...
             'GA_33.65_-84.433_2007_2009.csv_24_q_7_30 '; ...
             'IA_41.017_-94.367_2007_2009.csv_24_q_7_30'; ...
             'NC_35.733_-81.383_2007_2009.csv_24_q_7_30'; ...
             'OK_36.2_-95.883_2007_2009.csv_24_q_7_30  '; ...
             'OR_45.55_-122.4_2007_2009.csv_24_q_7_30  ' ; ...
             'SC_33.967_-80.467_2007_2009.csv_24_q_7_30'];
         
    xRange = 250;
elseif strcmp(dataType,'wind')
    path   = 'google_dc/errors/AR/WIND/'; 
    files  = [
             'AL_34.65_-86.783_merge.csv_24_q_7_30 '; ...
             'GA_33.65_-84.433_merge.csv_24_q_7_30 '; ...
             'IA_41.017_-94.367_merge.csv_24_q_7_30'; ...
             'NC_35.733_-81.383_merge.csv_24_q_7_30'; ...
             'OK_36.2_-95.883_merge.csv_24_q_7_30  '; ...
             'OR_45.55_-122.4_merge.csv_24_q_7_30  ' ; ...
             'SC_33.967_-80.467_merge.csv_24_q_7_30']; 
    xRange = 250;
elseif strcmp(dataType,'price')
    path   = 'prices/errors/AR/'; 
    files  = [  'price_0029.76_-095.36_tx.houston.csv_24_q_7_30 ' ...
              ; 'price_0037.34_-121.91_ca.np15.csv_24_q_7_30    ' ...
              ; 'price_0039.66_-082.01_pjm.ohio.csv_24_q_7_30   ' ...
              ; 'price_0039.94_-083.31_pjm.aep.csv_24_q_7_30    ' ...
              ; 'price_0040.54_-074.40_pjm.nj.csv_24_q_7_30     ' ...
              ; 'price_0040.75_-074.00_ny.nyc.csv_24_q_7_30     ' ...
              ; 'price_0041.85_-087.63_pjm.chi.csv_24_q_7_30    ' ...
              ; 'price_0042.36_-071.06_ne.bos.csv_24_q_7_30     ' ...
          ];  
    xRange = 250;
elseif strcmp(dataType,'workload')    
    path = 'workload/errors/AR/'; 
    files  = [   'AL_0034.77_-086.68_workload.csv_24_1 ' ...
                          ; 'GA_0033.72_-084.47_workload.csv_24_1 ' ...
                          ; 'IA_0041.58_-093.68_workload.csv_24_1 ' ...
%                           ; 'NC_0035.99_-078.90_workload.csv_24_1 ' ...
                          ; 'OK_0035.48_-097.50_workload.csv_24_1 ' ...
                          ; 'OR_0044.81_-122.68_workload.csv_24_1 ' ...
                          ; 'SC_0034.07_-081.19_workload.csv_24_1 ' ...                          
                          ; 'VA_0038.02_-078.57_workload.csv_24_1 ' ...   
                          ; 'TN_0036.07_-086.72_workload.csv_24_1 ' ...   
                          ; 'AR_0034.57_-092.64_workload.csv_24_1 ' ...   
                          ; 'MA_0042.35_-071.55_workload.csv_24_1 ' ... 
                          ];
    xRange = 250;
end
if strcmp(dataType,'solar')    
    hourStart = 9;
    hourEnd = 18;
else
    hourStart = 1;
    hourEnd = 24;   
end

i = 1;
for iDay = hourStart:hours:hourEnd    
    legendStr{i} = [num2str(iDay) ':00'];
    i = i + 1;
end

fileLen = length(files(:,1));
XF = (-RANGE:1:RANGE); len = length(XF);
DF = zeros(i,len);
for iFile = 1:fileLen
    file = files(iFile,:);
    load(strcat(path , file, '.mat'));
    
    if ~strcmp(dataType,'price')
        predictedValues = abs(predictedValues);
    end
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

    i = 1;
    for iDay = hourStart:hours:hourEnd
        valTemp = values(iDay,:); 
        valTemp = valTemp - mean(valTemp);
        valTemp = valTemp(valTemp>-xRange);
        valTemp = valTemp(valTemp<xRange);        
        [f,xf] = ksdensity(valTemp);
        Vq = interp1(xf,f,XF);
        Vq(isnan(Vq))  =  0;
        DF(i,:) = DF(i,:) + Vq;
%         plot(xf,f);
%         hold on;
        i = i+ 1;
    end
    
end

DF = DF/fileLen;

figure1 = figure;
axes1 = axes('Parent',figure1);


if hours > 1
    plot(XF,DF(1,:), '-.b', 'linewidth', LineWidth);
    hold on;
    plot(XF,DF(2,:), '--r','linewidth', LineWidth);
    hold on;
    plot(XF,DF(3,:), '-b','linewidth', LineWidth);
    hold on;
    plot(XF,DF(4,:), '-r','linewidth', LineWidth);
    hold on;
else
    xCutOff=200;
    for iDay = hourStart:hours:hourEnd
        plot(XF,DF(iDay,:));
        hold on;
        i = i + 1;
       
        cutOffList = XF>=-xCutOff & XF<=xCutOff;        
        probabilities = DF(iDay,cutOffList);
        xf = XF(cutOffList);
    %     xf = [-100 xf];    probabilities = [0 probabilities];
    %     plot(xf,probabilities);
        save(['probabilities/' dataType '/probability_' int2str(iDay) '.mat'],'probabilities', 'xf');
    %     [D, PD] = allfitdist(valTemp, 'PDF');
    end
end

i = 1;
if hours > 1
    for iDay = hourStart:hours:hourEnd
        stdVal = round(sqrt(sum(XF.^2 .* DF(i,:))));
%         legendStr{i} = [num2str(iDay) ':00' ' \sigma=' num2str(stdVal)];
        i = i+1;
        if strcmp(dataType, 'wind')
            dim = [.15 .8-i/10 .3 .3];
        else
            dim = [.2 .8-i/10 .3 .3];
        end
%         annotation(figure1,'textbox',dim,...
%         'String',{['\sigma =' num2str(stdVal)]},'FitBoxToText','on','EdgeColor','none',...
%         'FontSize',	fontLegend);
    end
end

if isFit   
    %        distname = 'generalized extreme value';
    distname = 'tlocationscale';
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

if isSAVE
    probabilities = f;
    save(['probabilities/' dataType '/probability_' int2str(iDay) '.mat'],'probabilities');
end
% [D, PD] = allfitdist(valTemp, 'PDF');
% Fit

%% plot
grid on;

axis([-xRange xRange 0 14e-3]) 
% set(gca,'fontsize',fontAxis) 
% axis([1 10 0 3.2]);
legend(legendStr,'Location','northwest','FontSize',fontLegend,'Orientation','vertical');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 4.0 3.0]);
xlabel('prediction error (%)','FontSize',fontAxis);
ylabel('probability density','FontSize',fontAxis);
print ('-depsc', [figPath 'ar_hourly_pdf_error_' dataType '.eps']);