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
folder = 'NREL/';
folderList = regexp(genpath(folder),['[^;]*'],'match');
folderList = folderList(1,2:length(folderList));
numOfFolder = length(folderList);
numOfFilePerFolder = 1;
numOfFile = numOfFolder*numOfFilePerFolder;

%numOfFile = 10;% 137 % length(excelFiles);
fileList = cell(numOfFile,1);
dataList = cell(numOfFile,1);
iFile = 0;
for iFolder = 1:numOfFolder
    folder = strcat(folderList{iFolder},'/');
    filePath = fullfile(strcat(folder,'/Actual_*.csv')); %AL is Alabama
    excelFiles = dir(filePath);
    % Read information from file names
    for i = 1:numOfFilePerFolder
        iFile = iFile + 1;
        fileList{iFile} = excelFiles(iFile).name;
        f = fopen(strcat(folder,excelFiles(iFile).name));
        dataList{iFile} = textscan(f, '%s %f', 'Delimiter', ',', 'HeaderLines', 1);
        datetimeList(iFile, :) = dataList{iFile}{1};
        solarPowerList(iFile, :) = dataList{iFile}{2};
        fclose(f);
    end
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
%save('deltas_Actual_13_SE_states','pvDistances','corrList');
%save('deltas_Actual_13_SE_states_30mins','pvDistances','corrList');
%save('deltas_Actual_13_SE_states_60mins','pvDistances','corrList');
%save('deltas_Actual_13_SE_states_180mins','pvDistances','corrList');
scatter(pvDistances, corrList);
hold on;
xInput = 1:1200;
yOutput = getCurveFitData(xInput, pvDistances, corrList);
plot(xInput,yOutput);  
xlabel('Distance (km)');
ylabel('Correlation coefficient');
axis([0 1200 0 1]);
hold off;