clear; close all; clc;

addpath('lib/libsvm-3.20/matlab');
addpath('../functions');

year = 365;
train_days = 2*365;
test_days = 365;
avg_step = 30;
oneDay = 24;
delay = 24;

trainDuration = 1:train_days*oneDay;
testDuration = train_days*oneDay+1:train_days*oneDay+test_days*oneDay;
totalLen = (train_days+test_days)*oneDay;
trainLen = train_days*oneDay;
testLen = test_days*oneDay;

period = 365*oneDay;
    folder = 'NREL_SAM\SOLAR\'

stateSAMPVsettings = cellstr([  'AL_34.65_-86.783_2007_2009.csv ' ...
                              ; 'GA_33.65_-84.433_2007_2009.csv ' ...
                              ; 'IA_41.017_-94.367_2007_2009.csv' ...
                              ; 'NC_35.733_-81.383_2007_2009.csv' ...
                              ; 'OK_36.2_-95.883_2007_2009.csv  ' ...
                              ; 'OR_45.55_-122.4_2007_2009.csv  ' ...
                              ; 'SC_33.967_-80.467_2007_2009.csv' ...
                              ; 'LA_31.17_-91.87_2007_2009.csv  ' ...
                              ; 'CA_037.00_-120.00_2007_2009.csv' ...
                              ; 'FL_027.77_-081.69_2007_2009.csv' ...
                              ; 'ND_047.53_-099.78_2007_2009.csv' ...
                              ; 'NE_041.13_-098.27_2007_2009.csv' ...
                              ; 'NY_042.17_-074.95_2007_2009.csv' ...
                              ; 'TX_031.05_-097.56_2007_2009.csv' ...
                              ; 'WA_047.40_-121.49_2007_2009.csv' ...
                              ; 'ME_44.69_-69.38_2007_2009.csv  ' ...
                              ; 'MI_43.33_-84.54_2007_2009.csv  ' ...
                              ; 'MO_38.46_-92.29_2007_2009.csv  ' ...
                              ; 'WY_42.76_-107.3_2007_2009.csv  ' ...
                              ; 'SC_33.967_-80.467_2007_2009.csv' ...
                              ]);
stateNum = length(stateSAMPVsettings);
for stateIdx = 1:stateNum


    latArray = [34.65 33.65 41.017 35.733 36.2 45.55 33.967];
    lonArray = [-86.783 -84.433 -94.367 -81.383 -95.883 -122.4 -80.467];

    if (stateIdx <= 7)
        Lat = latArray(stateIdx);
        Lon = lonArray(stateIdx);
    else
        fileName = stateSAMPVsettings{stateIdx};
        Lat = str2num(fileName(4:9));
        Lon = str2num(fileName(11:17));
    end


    % Load data
    %importDataScript
    [Datetimes,AmbienttemperatureC,ACinverterpowerW,Angleofincidencedeg, ...
            BeamirradianceWm2,DCarraypowerW,DiffuseirradianceWm2,GlobalhorizontalirradianceWm2, ... 
            ModuletemperatureC,PlaneofarrayirradianceWm2,PowergeneratedbysystemkW,Shadingfactorforbeamradiation, ... 
            Sunupoverhorizon01,TransmittedplaneofarrayirradianceWm2,Windspeedms] = ...
            importSAMSolar(strcat(folder,stateSAMPVsettings{stateIdx}));
    values = PowergeneratedbysystemkW;

    predictedValues = zeros(length(testDuration),1);

    for i=1:testLen      
        idxList = [];
        numOfperiod = floor(trainLen/period);
        for j=1:numOfperiod
            startidx = trainLen + i-avg_step/2*oneDay+1 - period;
            endIdx = trainLen + i + avg_step/2*oneDay - period;
            tempList = max(startidx,1):oneDay:min(endIdx,totalLen);    
            idxList = [idxList tempList];    
        end    
        pastValues = values(idxList);
        predictedValues(i) = mean(pastValues);
    end
    expectedValues = values(testDuration);

    errors = expectedValues - predictedValues;
    mae = mean(abs(errors))

    %%
    % close all;
    % day = 1;
    % range = (day-1)*24+1: day*24+24*15;
    % plot(predictedValues(range));
    % hold on;
    % plot(expectedValues(range));
    % legend('predict','real');

    %%
    save(['errors/AVG/SOLAR/' stateSAMPVsettings{stateIdx} '.mat'], 'predictedValues' , 'expectedValues', 'errors', 'Lat', 'Lon' );
end