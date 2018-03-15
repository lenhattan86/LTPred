function [commandOut] = cmd(commandStr, isPrint)
%CMD Summary of this function goes here
%   Detailed explanation goes here
    if nargin<=1
        isPrint = false;        
    end
    
    [status, commandOut] = system(commandStr);   
    if status==1
        error(commandOut);    
    elseif isPrint
        disp(commandOut);
    end
end

