%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Computational Problem Set, Enviro I, Problem 2
% Zachary Kuloszewski
%
% Last Edit Date: Nov 7, 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set directories
clear; clc;

cd '/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents/';
cd 'GitHub/phd_psets/year2/environmental';
addpath(genpath('figures'));
addpath(genpath('functions'));

%% Problem 2
% Interpolating the state space

%% part 2a - set up state space, parameters
N     = 501; 
S_tot = 1000;
r     = 0.05;

delta = 1/(1+r);
S     = linspace(0,S_tot,N);

% set up action space
A     = linspace(0,sqrt(S_tot),N);
A     = A.^2;
nA    = numel(A);

% define utility of extraction

% pick utility function of interest
u_fun_flag = 2; % choose 1 or 2

if u_fun_flag == 1
    u = @(x) 2*x.^0.5;
elseif u_fun_flag == 2
    u = @(x) 5*x-0.05*x.^2;
end

% define flow utility matrix
U = u(repmat(A,nA,1));

% def -inf upper triangular matrix
infs    = repmat(-Inf, N);
flow_UT = triu(infs,1);

% sum to get final flow utility matrix
U   = U + flow_UT;

%% part 2b - define interpolated transition matrix

% identify state in next period
% init matrix w same dimension as flow utility
transition = nan(N,nA);

for i=1:N % iter through rows
    for j=1:nA % iter through columns
        if j > i % if extracting more than full stock
            transition(i,j) = 1;
        else
            transition(i,j) = i-j+1;
        end
    end
end

% state transition matrix
T = nan(N,N*nA);
rows = 1:501;

for k=1:nA
%     inds = S - A(k);
%     inds(inds<=0) = 1;

    inds = zeros(N,2);
    wts  = zeros(N,2);
    
    %here we need to find the weights
    for i=1:N
        [inds(i,:),wts(i,:)] = interp_states(S(i),k,S,A);
    end

    inds_stack = [inds(:,1); inds(:,2)];
    wts_stack  = [wts(:,1) ; wts(:,2)];
    rows_stack = [rows; rows];

    T(:,1+(k-1)*N:k*N) = sparse(rows_stack(wts_stack > 0),inds_stack(wts_stack > 0), ...
        wts_stack(wts_stack > 0),N,nA);
end

T = sparse(T);
