%%%newNARX code 24/4/2013
X = tonndata(trainingData,false,false);
T = tonndata(trainingData,false,false);
  %  X = con2seq(x);
  %  T = con2seq(t);
%% 2. Data preparation
delay = 72;
N = 24; % Multi-step ahead prediction
% Input and target series are divided in two groups of data:
% 1st group: used to train the network
inputSeries  = X(1:end-N-delay);
targetSeries = T(delay+1:end-N);
% 2nd group: this is the new data used for simulation. inputSeriesVal will 
% be used for predicting new targets. targetSeriesVal will be used for
% network validation after prediction
inputSeriesVal  = X(end-N-delay+1:end-delay);
targetSeriesVal = T(end-N+1:end); % This is generally not available
%% 3. Network Architecture

neuronsHiddenLayer = 50;
% Network Creation
net = narxnet(1:delay,1:delay,neuronsHiddenLayer);
%% 4. Training the network
[Xs,Xi,Ai,Ts] = preparets(net,inputSeries,{},targetSeries); 
net = train(net,Xs,Ts,Xi,Ai);
view(net)
Y = net(Xs,Xi,Ai); 
% Performance for the series-parallel implementation, only 
% one-step-ahead prediction
perf = perform(net,Ts,Y);
%% 5. Multi-step ahead prediction
inputSeriesPred  = [inputSeries(end-delay+1:end),inputSeriesVal];
targetSeriesPred = [targetSeries(end-delay+1:end), con2seq(nan(1,N))];
netc = closeloop(net);
view(netc)
[Xs,Xi,Ai,Ts] = preparets(netc,inputSeriesPred,{},targetSeriesPred);
yPred = netc(Xs,Xi,Ai);
perf = perform(net,yPred,targetSeriesVal);
figure;
plot([cell2mat(targetSeries),nan(1,N);
      nan(1,length(targetSeries)),cell2mat(yPred);
      nan(1,length(targetSeries)),cell2mat(targetSeriesVal)]')
legend('Original Targets','Network Predictions','Expected Outputs')