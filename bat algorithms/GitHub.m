function [outputArg1,outputArg2] = GitHub(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;

clc;
clear;
clear global;


% Display help
%  help bat_algorithm.m

% Default parameters
if nargin<1
    para=[20 1000 0.5 0.5];
end

n=para(1);      % Population size, typically 10 to 40
N_gen=para(2);  % Number of generations
A=para(3);      % Loudness  (constant or decreasing)
r=para(4);      % Pulse rate (constant or decreasing)

end

