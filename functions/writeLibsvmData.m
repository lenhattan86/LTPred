function [result] = writeLibsvmData( fileName, labels, values)
%WRITELIBSVMDATA Summary of this function goes here
%   Detailed explanation goes here    
    fileID = fopen(fileName,'w');
    numberOfFeatures = length(values(1,:));
    for i = 1:length(values)
        fprintf(fileID, '%f',labels(i));
        for iFeature=1:numberOfFeatures            
            fprintf(fileID, ' %d:%f', iFeature, values(i,iFeature));
        end        
        fprintf(fileID, '\n');
        
    end
    fclose(fileID);
    result = 1;
end

