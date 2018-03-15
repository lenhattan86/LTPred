%% Load processed data and plot them.

%fileList = cell(10,1);
clear; clc; close all;
fileList{1} = 'deltas_AL_Actual_137_sites.mat';
fileList{2} = 'deltas_AL_Actual_137_sites_30mins.mat';
fileList{3} = 'deltas_AL_Actual_137_sites_60mins.mat';
fileList{4} = 'deltas_AL_Actual_137_sites_180mins.mat';


for iFile = 1:length(fileList);
    load(fileList{iFile});
    fileList{iFile}
    scatter(pvDistances, corrList);
    hold on;
    xInput = 0:550;
    yOutput = getCurveFitData(xInput, pvDistances, corrList);
    plot(xInput,yOutput,'LineWidth', 2);    
    xlabel('Distance (km)');
    ylabel('Correlation cofficient');
    axis([0 550 0 1]);
    hold on;
    if iFile < length(fileList)
        % figure;
    end
end
title('Correlation of deltas with distances'); 
legend('5 min deltas','5 min deltas','30 min deltas','30 min deltas', ...
    '60 min deltas','60 min deltas','180 min deltas','180 min deltas');