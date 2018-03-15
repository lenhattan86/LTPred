function output = filterNoise( array, noiseVal, range)  
    if nargin<=2
        range = [-inf inf];
    end
    x=1:length(array);
    y=array;    
    
    xi=x(find(y~=noiseVal));
    yi=y(xi);
    output=interp1(xi,yi,x,'linear');
    
    xi=x(find(y<range(2) & y>range(1)));
    yi=y(xi);
    output=interp1(xi,yi,x,'linear');  
end

