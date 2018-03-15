%% This script is to load the solar data and compute the correlation in space & time domains.

%% Reset
clc; clear; close all;    
%% Add class paths
addpath('functions');

%% Initialize parameters
SAMPLE_TIME = 5; % constant 5 mins.
sampleTime = 180; % 5 minutes is the minimum insolation.

%T = (31+28+31+30+31+30+31+31+30+31+30+31)*24*60/SAMPLE_TIME;
T = (31+28)*24*60/SAMPLE_TIME; % 1 month

%% Load data from excel files in a folder
folder = 'NREL/AL_PV_2006/';
filePath = fullfile(strcat(folder,'Actual_*.csv')); %AL is Alabama
excelFiles = dir(filePath);

% Read information from file names
numOfFile = 137;% 137 % length(excelFiles);
fileList = cell(numOfFile,1);
dataList = cell(numOfFile,1);
for iFile = 1:numOfFile
    fileList{iFile} = excelFiles(iFile).name;
    f = fopen(strcat(folder,excelFiles(iFile).name));
    dataList{iFile} = textscan(f, '%s %f', 'Delimiter', ',', 'HeaderLines', 1);
    datetimeList(iFile, :) = dataList{iFile}{1};
    solarPowerList(iFile, :) = dataList{iFile}{2};
    fclose(f);
end
DATA_LENGTH = length(solarPowerList(1,:));

% Normalize solar data: because of the scale of PV plants are different.
normSolarPowerList = zeros(numOfFile, T);
for iFile = 1:numOfFile
    [x1 x2 capacity] = getFileInfo(fileList{iFile});
    normSolarPowerList(iFile,:) = (1/capacity)*solarPowerList(iFile,1: T);
    %normSolarPowerList(iFile,:) = solarPowerList(iFile,1: T);
end

% Calculate the distance between each pair of PV plant.
%pvDistances = zeros(numOfFile);
iIndex = 0;
for iRow = 1:numOfFile
    for iCol = 1:iRow
        iIndex = iIndex + 1;
        [lat1 lon1 x] = getFileInfo(fileList{iRow});
        [lat2 lon2 x] = getFileInfo(fileList{iCol});        
        [pvDistances(iIndex) x] = lldistkm([lat1, lon1],[lat2, lon2]);
    end
end

% Calculate deltas (step changes) in 5 mins, 30 mins, 60 mins.
sampleLength = sampleTime/SAMPLE_TIME;
deltasLength = T/sampleLength;
deltasMatrix = zeros(numOfFile, deltasLength);
for iFile = 1:numOfFile
    for i = 2:deltasLength
        m = (i-2)*sampleLength; 
        n = (i-1)*sampleLength;
        q = (i)*sampleLength;    
        deltasMatrix(iFile, i) = mean(normSolarPowerList(iFile, n+1:q)) - ...
                                    mean(normSolarPowerList(iFile, m+1:n));
    end
end

%% Calculate the correlation of deltas in space domain.
%corrCofficients = corrcoef(deltasMatrix);
iIndex = 0;
%corrList = zeros(numOfFile);
for iRow = 1:numOfFile
    for iCol = 1:iRow
        iIndex = iIndex + 1;
        %corrList(iIndex) = corr(normSolarPowerList(iRow,:)', normSolarPowerList(iCol,:)');
        corrList(iIndex) = corr(deltasMatrix(iRow,:)', deltasMatrix(iCol,:)');          
    end
end

%% plot the correlation of deltas in the spacial scale.
%save('deltas_AL_Actual_137_sites','pvDistances','corrList');
%save('deltas_AL_Actual_137_sites_30mins','pvDistances','corrList');
%save('deltas_AL_Actual_137_sites_60mins','pvDistances','corrList');
%save('deltas_AL_Actual_137_sites_180mins','pvDistances','corrList');
%load('deltas_AL_Actual_137_sites_180mins.mat');
scatter(pvDistances, corrList);
hold on;
xInput = 1:550;
yOutput = getCurveFitData(xInput, pvDistances, corrList);
plot(xInput,yOutput);  
xlabel('Distance (km)');
ylabel('Correlation coefficient');
axis([0 550 0 1]);
hold off;

%% percentile
percentiles = 0:100;
cumProbValue = prctile(abs(deltasMatrix(3,:)),percentiles);
plot(cumProbValue, percentiles);