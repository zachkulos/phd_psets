%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Empirical Analysis II - Problem Set 6, Question 16
% Zachary Kuloszewski
% February 28, 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
close all;
warning  off;
cd /Users/zachkuloszewski/Desktop/Classes/Metrics/Q2/psets/ps6

%% import / format data

% read in csv
dat = readtable('problem_16.csv');
dat.Properties.VariableNames{1} = 'Time';

% create lags for cons
for i=1:4
    evalc(strcat('dat.logC_lag', num2str(i), '= lagmatrix(dat.logC_diff,', ...
        num2str(i), ');')); 
end
% D-C lags
for i=1:5
    evalc(strcat('dat.logDC_lag', num2str(i), '= lagmatrix(dat.logD_logC,', ...
        num2str(i), ');'));
end
% E-C lags
for i=1:5
    evalc(strcat('dat.logEC_lag', num2str(i), '= lagmatrix(dat.logE_logC,', ...
        num2str(i), ');'));
end
% rearrange columns to match data
dat = [dat(:,[1:2 5:8]) dat(:,[3 14:18]) dat(:,[4 9:13]) ];
dat(1:5,:) = [];

% place unlagged variables in separate table
Zdat = dat(:,{'logC_diff','logE_logC','logD_logC'});
Xdat = dat(:,[3:6 8:12 14:end]);

X = [ones(278,1) Xdat{:,:}];
Z = Zdat{:,:};

r1 = X;
r2 = [X dat.logC_diff];
r3 = [r2 dat.logE_logC];

%% run regressions: OLS Estimates

z1_model = fitlm( Xdat{:,:}, dat.logC_diff);
z2_model = fitlm([Xdat{:,:} dat.logC_diff], dat.logE_logC);
z3_model = fitlm([Xdat{:,:} dat.logC_diff dat.logE_logC], dat.logD_logC);

% estimate zetas from OLS
zeta1 = sum((dat.logC_diff - r1*z1_model.Coefficients.Estimate).^2)^-1;
zeta2 = sum((dat.logE_logC - r2*z2_model.Coefficients.Estimate).^2)^-1;
zeta3 = sum((dat.logD_logC - r3*z3_model.Coefficients.Estimate).^2)^-1;

%% iterative posterior estimation z1

% init lambdas
lambda1 = zeros(15,15);
lambda2 = zeros(16,16);
lambda3 = zeros(17,17);

lambda_old = zeros(15,15);

% init c and d
c = 0;
d = 0;
b_old = zeros(15,1);

% struct for output
s1        = struct;
s1.c      = zeros(size(dat.Time));
s1.d      = zeros(size(dat.Time));
s1.b      = zeros(size(r1));
s1.lambda = cell(size(dat.Time));
s1.beta   = z1_model.Coefficients.Estimate;
s1.n      = z1_model.NumObservations;

for i=1:length(dat.Time)
    c           = c + 1;
    lambda1     = X(i,:)' * X(i,:) + lambda_old;
    b           = lambda1 \ (X(i,:)' * Z(i,1) + lambda_old * b_old);
    d           = Z(i,1)^2 - (b' * lambda1 * b) + ...
                        (b_old' * lambda_old * b_old) + d; 
    % store new values
    s1.d(i)      = d;
    s1.c(i)      = c;
    s1.b(i,:)    = b;
    s1.lambda{i} = lambda1;

    % store b and lambda values for next iter
    b_old       = b;
    lambda_old  = lambda1;
end
s1.zeta = zeta1;

disp(['precision for Z1 from OLS estimates: ' num2str(zeta1)]);
disp(['precision for Z1 from recursive updating: ' num2str(d^-1)]);

%% iterative posterior estimation z2 

% init c and d, lambda
lambda_old = zeros(16,16);
c = 0;
d = 0;
b_old = zeros(16,1);

% struct for output
s2   = struct;
s2.c = zeros(size(dat.Time));
s2.d = zeros(size(dat.Time));
s2.b = zeros(size(r2));
s2.lambda = cell(size(dat.Time));
s2.beta   = z2_model.Coefficients.Estimate;
s2.n      = z2_model.NumObservations;

% perform iteration
for i=1:length(dat.Time)
    c           = c + 1;
    lambda2     = r2(i,:)' * r2(i,:) + lambda_old;
    b           = lambda2 \ (r2(i,:)' * Z(i,2) + lambda_old * b_old);
    d           = Z(i,2)^2 - (b' * lambda2 * b) + ...
                        (b_old' * lambda_old * b_old) + d; 

    % store new values
    s2.d(i)      = d;
    s2.c(i)      = c;
    s2.b(i,:)    = b;
    s2.lambda{i} = lambda2;

    % store b and lambda values for next iter
    b_old       = b;
    lambda_old  = lambda2;
end

s2.zeta = zeta2;
disp(['precision for Z2 from OLS estimates: ' num2str(zeta2)]);
disp(['precision for Z2 from recursive updating: ' num2str(d^-1)]);

%% iterative posterior estimation z3

% init c and d, lambda
lambda_old = zeros(17,17);
c = 0;
d = 0;
b_old = zeros(17,1);

% struct for output
s3   = struct;
s3.c = zeros(size(dat.Time));
s3.d = zeros(size(dat.Time));
s3.b = zeros(size(r3));
s3.lambda = cell(size(dat.Time));
s3.beta   = z3_model.Coefficients.Estimate;
s3.n      = z3_model.NumObservations;

% perform iteration
for i=1:length(dat.Time)
    c           = c + 1;
    lambda3     = r3(i,:)' * r3(i,:) + lambda_old;
    b           = lambda3 \ (r3(i,:)' * Z(i,3) + lambda_old * b_old);
    
    d           = Z(i,3)^2 - (b' * lambda3 * b) + ...
                        (b_old' * lambda_old * b_old) + d; 
    % store new values
    s3.d(i)      = d;
    s3.c(i)      = c;
    s3.b(i,:)    = b;
    s3.lambda{i} = lambda3;

    % store b and lambda values for next iter
    b_old       = b;
    lambda_old  = lambda3;
end

s3.zeta = zeta3;
disp(['precision for Z3 from OLS estimates: ' num2str(zeta3)]);
disp(['precision for Z3 from recursive updating: ' num2str(d^-1)]);

%% Part 16d

% set seed
rng(1); 

% calculate matrices for state space models
mat_str = calcMatrices(s1,s2,s3);


