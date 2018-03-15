%% This file is to implement the popular time-series forecasting methods.
%  to predict the electricity prices 

%% Forecast linear system response into future

load iddata9 z9
model = ar(z9,4);
past_data = z9.OutputData(1:51); % double data

K = 100;
yf = forecast(model,past_data(1:50),K);

t = z9.SamplingInstants;
t1 = t(1:51);
t2 = t(51:150)';
plot(t1,past_data,t2,yf,'r')
legend('Measured','Forecasted')



