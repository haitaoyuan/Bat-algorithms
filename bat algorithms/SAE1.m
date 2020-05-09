function [outputArg1,outputArg2] = SAE1(inputArg1,inputArg2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% outputArg1 = inputArg1;
% outputArg2 = inputArg2;


% Load the training data.
[X,T] = iris_dataset;

% Train an autoencoder with a hidden layer of size 5 and a linear transfer function for the decoder. Set the L2 weight regularizer to 0.001, sparsity regularizer to 4 and sparsity proportion to 0.05.
hiddenSize = 5;
autoenc = trainAutoencoder(X, hiddenSize, ...
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ...
    'DecoderTransferFunction','purelin');

% Extract the features in the hidden layer.
features = encode(autoenc,X);

% Train a softmax layer for classification using the features .
softnet = trainSoftmaxLayer(features,T);

% Stack the encoder and the softmax layer to form a deep network.
stackednet = stack(autoenc,softnet);

% View the stacked network.
view(stackednet);

end

