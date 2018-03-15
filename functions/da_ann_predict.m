function y_da = da_ann_predict(pastData, Delay, K) 
    y_da        = zeros(1,K);
    xi1         = pastData(1:Delay)';
    x1          = pastData(Delay+1); 
    for t = 1:K                       
        [y1,xf1]    = ann_ntstool(x1,xi1);
        y_da(t)     = y1(1);
        xi1         = [xi1(2:Delay) y_da(t)];
        x1          = y_da(t);
    end
end

