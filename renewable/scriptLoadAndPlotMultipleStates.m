%% Load processed data and plot them.

%fileList = cell(10,1);
clear; clc; close all;
fileList{1} = 'deltas_Actual_13_SE_states.mat';
fileList{2} = 'deltas_Actual_13_SE_states_30mins.mat';
fileList{3} = 'deltas_Actual_13_SE_states_60mins.mat';
fileList{4} = 'deltas_Actual_13_SE_states_180mins.mat';


for iFile = 1:length(fileList);
    load(fileList{iFile});
    fileList{iFile}
    scatter(pvDistances, corrList);
    hold on;
    xInput = 0:1200;
    yOutput = getCurveFitData(xInput, pvDistances, corrList);
    plot(xInput,yOutput,'LineWidth', 2);    
    xlabel('Distance (km)');
    ylabel('Correlation cofficient');
    axis([0 1200 0 1]);
    hold on;
    if iFile < length(fileList)
        % figure;
    end
end
title('Correlation of deltas with distances'); 
legend('5 min deltas','5 min deltas','30 min deltas','30 min deltas', ...
    '60 min deltas','60 min deltas','180 min deltas','180 min deltas');