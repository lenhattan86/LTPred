function [DrybulbtempC,WetbulbtempC,DewpointtempC,Relativehumidity,Windspeedms1,Winddirectiondeg] = importSAMWeather(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [DRYBULBTEMPC,WETBULBTEMPC,DEWPOINTTEMPC,RELATIVEHUMIDITY,WINDSPEEDMS1,WINDDIRECTIONDEG]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [DRYBULBTEMPC,WETBULBTEMPC,DEWPOINTTEMPC,RELATIVEHUMIDITY,WINDSPEEDMS1,WINDDIRECTIONDEG]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [DrybulbtempC,WetbulbtempC,DewpointtempC,Relativehumidity,Windspeedms1,Winddirectiondeg] = importfile('AL_34.65_-86.783_weather.csv',2, 8761);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/10/17 22:58:52

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column2: double (%f)
%	column3: double (%f)
%   column4: double (%f)
%	column5: double (%f)
%   column6: double (%f)
%	column7: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*q%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
DrybulbtempC = dataArray{:, 1};
WetbulbtempC = dataArray{:, 2};
DewpointtempC = dataArray{:, 3};
Relativehumidity = dataArray{:, 4};
Windspeedms1 = dataArray{:, 5};
Winddirectiondeg = dataArray{:, 6};


