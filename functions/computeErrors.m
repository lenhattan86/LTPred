function [ normalizedErrors ] = computeErrors(errors, expectedValues, method)
    if strcmp(method,'rmse')
        normalizedErrors = sqrt(mean(errors.^2))/mean(expectedValues)*100;
    elseif strcmp(method,'mae')
        normalizedErrors = mean(abs(errors))/mean(expectedValues)*100;
    else
        error('Wrong method');
    end
end

