% Reset
clc; clear; close all;    
% Add class paths
addpath('functions');

%% Load data
path = 'errors/'; 
files = ['Actual_34.05_-86.05_2006_DPV_36MW_5_Min '; ...
         'Actual_33.25_-84.25_2006_DPV_21MW_5_Min '; ...
         'Actual_41.15_-94.85_2006_UPV_38MW_5_Min '; ...
         'Actual_35.15_-81.15_2006_DPV_34MW_5_Min '; ...
         'Actual_36.05_-95.45_2006_UPV_80MW_5_Min '; ...
         'Actual_45.35_-122.35_2006_UPV_20MW_5_Min'; ...
         'Actual_33.05_-80.25_2006_UPV_128MW_5_Min'];
filesCell = cellstr(files);
numOfFile = length(files(:,1));

%errorsArray;
LatArrays = zeros(1,numOfFile);
LonArrays = zeros(1,numOfFile);
for i=1:numOfFile
    load(strcat(path,files(i,:),'.mat'));
    errorArray(i,:) = errors;
    LatArrays(i) = Lat;
    LonArrays(i) = Lon;
end

%%
DATA_LENGTH = length(errorArray(1,:));

% Calculate the distance between each pair of PV plant.
%pvDistances = zeros(numOfFile);
iIndex = 0;
for iRow = 1:numOfFile
    for iCol = 1:iRow
        iIndex = iIndex + 1;  
        [pvDistances(iIndex) x] = lldistkm([LatArrays(iRow), LonArrays(iRow)],[LatArrays(iCol), LonArrays(iCol)]);
    end
end

%% Calculate the correlation of deltas in space domain.
%corrCofficients = corrcoef(deltasMatrix);
iIndex = 0;
%corrList = zeros(numOfFile);
for iRow = 1:numOfFile
    for iCol = 1:iRow
        iIndex = iIndex + 1;
        corrList(iIndex) = corr(errorArray(iRow,:)', errorArray(iCol,:)');          
    end
end

%% plot the correlation of deltas in the spacial scale.
scatter(pvDistances, corrList);
hold on;
xInput = 1:1200;
%yOutput = getCurveFitData(xInput, pvDistances, corrList);
%plot(xInput,yOutput);  
xlabel('Distance (km)');
ylabel('Correlation coefficient');
%axis([0 1200 0 1]);