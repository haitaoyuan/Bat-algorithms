function [AE_net] = elm_AE(Tinputs,Tsinputs,NumberofHiddenNeurons,ActivationFunction,D_ratio,DB,frame)
% Input:
% Tinputs               - training data set
% Tsinputs              - testing data set
% NumberofHiddenNeurons - Number of hidden neurons assigned to the ELM
% D_ratio               - the ratio of noising features in each input frame
                        % ex: D_ratio =0.6 : 60% = gaussian noise  is added with  each input frame    
% DB                    - the power of white gaussian noise in decibels                     
% ActivationFunction    - Type of activation function:
%                           'sig' for Sigmoidal function
%                           'sin' for Sine function
%                           'hardlim' for Hardlim function
%                           'tribas' for Triangular basis function
%                           'radbas' for Radial basis function (for additive type of SLFNs instead of RBF type of SLFNs)
% frame                 - divide data into frames to add different type of noise
% Output: 
%                       - AE_net: this variable contain every imporatant
%                         information about the traind AE
%
%
    %%%%    Authors:        TAREK BERGHOUT
    %%%%    BATNA 2 TECHNOLOGICAL UNIVERSITY, ALGERIA
    %%%%    EMAIL:          berghouttarek@gmail.com


%% scale training dataset
T=Tinputs';T = scaledata(T,0,1);% memorize originale copy of the input and use it as a target
P=Tinputs';
%% scale training dataset
TV.T=Tsinputs';TV.T = scaledata(TV.T,0,1);% memorize originale copy of the input and use it as a target
TV.P=Tsinputs';TV.P = scaledata(TV.P,0,1);% temporal input
TVT=TV.T;%save acopy as an output of the function

%% in the 1st and 2nd step we will corrupte the temporal input
PtNoise=zeros(size(P));
i=1;
while i < size(P,2)-frame
gen=randi([0,1],1,1);
PNoise=[];

%%% 1st step: generate set of indexes to set some input's values to zero later 
%%% (here we set them randomly and you can choose them by probability)%%%
[zeroind] = dividerand(size(P,1),1-D_ratio,0,D_ratio);% generate indexes
%%% 2nd step: add gaussian noise 
if gen==1
Noise=wgn(1,size(P,1),DB)';% generate white gaussian noise
else
Noise=zeros(1,size(P,1))'; 
end

for j=1:frame;%copy  noise
PNoise=[PNoise Noise];
end
if gen==1
for j=1:length(zeroind);% set to zero
    PNoise(zeroind(j),:)=0;
    P(zeroind(j),i:i+frame)=0;
end
end

PtNoise(:,i:i+frame-1)=PNoise;
i=i+frame;
end

P=P+PtNoise; % add gauussian noise (corrupte the input)
P = scaledata(P,0,1);% corrupted input
%% training phase
NumberofTrainingData=size(P,2);
NumberofTestingData=size(TV.P,2);
NumberofInputNeurons=size(P,1);
% Calculate weights & biases
start_time_train=cputime;
% Random generate input weights InputWeight  and biases  of hidden neurons
InputWeight=rand(NumberofHiddenNeurons,NumberofInputNeurons)*2-1;
BiasofHiddenNeurons=rand(NumberofHiddenNeurons,1);
tempH=InputWeight*P;
ind=ones(1,NumberofTrainingData);
BiasMatrix=BiasofHiddenNeurons(:,ind);               %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH=tempH+BiasMatrix;

%% Calculate hidden neuron output matrix H
switch lower(ActivationFunction)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H = 1 ./ (1 + exp(-tempH));
    case {'sin','sine'}
        %%%%%%%% Sine
        H = sin(tempH);    
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H = double(hardlim(tempH));
    case {'tribas'}
        %%%%%%%% Triangular basis function
        H = tribas(tempH);
    case {'relu'}
        %%%%%%%% linear rectifier unit
        H = max(tempH,0);
        %%%%%%%% More activation functions can be added here                
end
clear tempH;                                        %   Release the temparary array for calculation of hidden neuron output matrix H

%Calculate output weights OutputWeight (beta)
OutputWeight=pinv(H') * T';                            % implementation without regularization factor //refer to 2006 Neurocomputing paper
%OutputWeight=inv(eye(size(H,1))/C+H * H') * H * T';   % faster method 1 //refer to 2012 IEEE TSMC-B paper
%OutputWeight=(eye(size(H,1))/C+H * H') \ H * T';      % faster method 2 //refer to 2012 IEEE TSMC-B paper

%If you use faster methods or kernel method, PLEASE CITE in your paper properly: 

end_time_train=cputime;
TrainingTime=end_time_train-start_time_train;        %   Calculate CPU time (seconds) spent for training ELM

%%%%%%%%%%% Calculate the training accuracy
Y=(H' * OutputWeight)'    ;                          %   Y: the actual output of the corrupted training data

TrainingAccuracy=sqrt(mse(T - Y)) ;                  %   Calculate training accuracy (RMSE) 
%%%%%%%%%%%%%

%% testing phase

% Calculate the output of testing input
% we will no longer use InputWeight
% and also activation functon and biases
start_time_test=cputime;
H_test=OutputWeight*TV.P;                            %   (encoding)we will use the OutputWeight instead of old Inputweights
TY=(H_test' * pinv(OutputWeight'))';                 %   (decoding)TY: the actual output of the corrupted testing data
end_time_test=cputime;
TestingTime=end_time_test-start_time_test;           %   Calculate CPU time (seconds) spent by ELM predicting the whole testing data
TestingAccuracy=sqrt(mse(TV.T - TY)) ;               %   Calculate testing accuracy (RMSE) 

% save parameters
AE_net.x=P;% coruupted input
AE_net.Ytr_hat=Y; % estimated training output
AE_net.Yts_hat=TY;% estimated testing output
AE_net.Tr_Time=TrainingTime;
AE_net.Ts_Time=TestingTime;
AE_net.Tr_acc=TrainingAccuracy;
AE_net.Ts_acc=TestingAccuracy;
AE_net.beta=OutputWeight;

end