% ======================================================== %
% Files of the Matlab programs included in the book:       %
% Xin-She Yang, Nature-Inspired Metaheuristic Algorithms,  %
% Second Edition, Luniver Press, (2010).   www.luniver.com %
% ======================================================== %

% -------------------------------------------------------- %
% Bat-inspired algorithm for continuous optimization (demo)%
% Programmed by Xin-She Yang @Cambridge University 2010    %
% -------------------------------------------------------- %
% Usage: bat_algorithm([20 1000 0.5 0.5]);                 %


% -------------------------------------------------------------------
% This is a simple demo version only implemented the basic          %
% idea of the bat algorithm without fine-tuning the parameters,     %
% Then, though this demo works very well, it is expected that       %
% this demo is much less efficient than the work reported in        %
% the following papers:                                             %
% (Citation details):                                               %
% 1) Yang X.-S., A new metaheuristic bat-inspired algorithm,        %
%    in: Nature Inspired Cooperative Strategies for Optimization    %
%    (NISCO 2010) (Eds. J. R. Gonzalez et al.), Studies in          %
%    Computational Intelligence, Springer, vol. 284, 65-74 (2010).  %
% 2) Yang X.-S., Nature-Inspired Metaheuristic Algorithms,          %
%    Second Edition, Luniver Presss, Frome, UK. (2010).             %
% 3) Yang X.-S. and Gandomi A. H., Bat algorithm: A novel           %
%    approach for global engineering optimization,                  %
%    Engineering Computations, Vol. 29, No. 5, pp. 464-483 (2012).  %
% -------------------------------------------------------------------

% Main programs starts here
function [best,fmin,N_iter]=bat_algorithm(para)

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

% This frequency range determines the scalings
% You should change these values if necessary
Frequency_min=0;         % Frequency minimum
Frequency_max=100;         % Frequency maximum
% Iteration parameters
N_iter=0;       % Total number of function evaluations
% Dimension of the search variables
d=10;           % Number of dimensions
% Lower limit/bounds/ a vector
Lb=-2*ones(1,d);
% Upper limit/bounds/ a vector
Ub=2*ones(1,d);

% Initializing arrays
Frequency=zeros(n,1);   % Frequency
Velocities=zeros(n,d);   % Velocities

% Initialize pulse rates ri and the loudness
% Ai***********************************************************************
loudness=ones(n,1);   % the loudness Ai
gamma=0.9;
for i=1:n
    loudness(i,1)=1+(2-1)*rand;
end

pulse_rates=zeros(n,1);   % the rate ri of pulse emission
pulse_rates0=zeros(n,1);   % the rate ri of pulse emission
alpha=0.9;
for i=1:n
    pulse_rates(i,1)=0+(1-0)*rand;
end
pulse_rates0=pulse_rates;

% Initialize the population/solutions
for i=1:n
    x(i,:)=Lb+(Ub-Lb).*rand(1,d);
    Fitness(i)=Fun(x(i,:));
end

% Find the initial best solution
[fmin,I]=min(Fitness);
best=x(I,:);

% ======================================================  %
% Note: As this is a demo, here we did not implement the  %
% reduction of loudness and increase of emission rates.   %
% Interested readers can do some parametric studies       %
% and also implementation various changes of A and r etc  %
% ======================================================  %

% Start the iterations -- Bat Algorithm (essential part)  %
for t=1:N_gen
    % Loop over all bats/solutions
    for i=1:n
        Frequency(i)=Frequency_min+(Frequency_max-Frequency_min)*rand;
        Velocities(i,:)=Velocities(i,:)+(x(i,:)-best)*Frequency(i);
        S(i,:)=x(i,:)+Velocities(i,:);
        % Apply simple bounds/limits
        x(i,:)=simplebounds(x(i,:),Lb,Ub);
        
        % Pulse rate
        if rand>pulse_rates(i,1)%r_{i}********************************
            % The factor 0.001 limits the step sizes of random walks
            S(i,:)=best+0.001*randn(1,d);
            %             S(i,:)=best+(sum(loudness(:,1))/n)*randn(1,d);%********************************
        end
        
        %Generate a new solution by flying
        %randomly********************************Causion, 0.001 could be
        %adjust for each problem
        S(i,:)=S(i,:)+0.001*randn(1,d);
        %         S(i,:)=S(i,:)+(sum(loudness(:,1))/n)*randn(1,d);%********************************
        
        % Evaluate new solutions
        Fnew=Fun(S(i,:));
        % Update if the solution improves, or not too loud
        if (Fnew<Fun(best)) && (rand<loudness(i,1))%A_{i}********************************
            x(i,:)=S(i,:);
            Fitness(i)=Fnew;
            %Increase ri and reduce Ai********************************
            loudness(i,1)=alpha*loudness(i,1);
            pulse_rates(i,1)=pulse_rates0(i,1)*(1-exp(-gamma*t));
        end
        
        % Update the current best solution
        %         if Fitness(i)<fmin
        %             best=x(i,:);
        %             fmin=Fitness(i);
        %         end
        
        if Fnew<fmin
            best=S(i,:);
            fmin=Fnew;
        end
        
    end
    N_iter=N_iter+n;
end
% Output/display
disp(['Number of evaluations: ',num2str(N_iter)]);
disp(['Best =',num2str(best),' fmin=',num2str(fmin)]);

% Application of simple limits/bounds
function s=simplebounds(s,Lb,Ub)
% Apply the lower bound vector
ns_tmp=s;
I=ns_tmp<Lb;
ns_tmp(I)=Lb(I);

% Apply the upper bound vector
J=ns_tmp>Ub;
ns_tmp(J)=Ub(J);
% Update this new move
s=ns_tmp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective function: your own objective function can be written here
% Note: When you use your own function, please remember to
%       change limits/bounds Lb and Ub (see lines 52 to 55)
%       and the number of dimension d (see line 51).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function z=Fun(u)
% Sphere function with fmin=0 at (0,0,...,0)
z=sum(u.^2);
%%%%% ============ end ====================================


