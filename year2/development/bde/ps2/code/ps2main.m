%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Problem Set 2 - Behavioral Development Economics
% Zachary Kuloszewski
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set directories
clear; clc;

cd '/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents/';
cd 'GitHub/phd_psets/year2/development/bde/ps2';
addpath(genpath('code'));
addpath(genpath('code/functions'));
addpath(genpath('output'));

%% set baseline parameter values

% tax levels
tau_h = 100;
tau_l = 50;

% incentive rate
inc = 0.5; 

% distributional parameters for respondent valuation of good
mu_v    = 40;
sigma_v = 50;

mu_s    = 1;
sigma_s = 2;

p_l = 0.001;
p_h = 0.02;

%% Question 1.1 

% function calculates all moments analytically
% arguments: (tau_h, tau_l, p_h, p_l, mu_v, sigma_v, mu_s, sigma_s, inc)
m = calculate_moments(tau_h, tau_l, p_h, p_l, mu_v, sigma_v, ...
                   0, 0, 0);

%% Question 1.2
% plot static analytical moments
figure;
bar(m(5:8));
set(gca,'xticklabel', ...
    {'$p_l$, $\tau_l$','$p_h$, $\tau_l$','$p_l$, $\tau_h$','$p_h$, $\tau_h$'}, ...
    'TickLabelInterpreter', 'latex');
title('Moments for Zero Incentive')

saveas(gcf,'part1_1.jpeg');
close all;

%% Question 1.3

%%% simulate data
n = 12000;
rng(01272023);

% assign equal sample to each tau, p cell
p_i   = [repelem(p_l,n/2) repelem(p_h,n/2)]';
tau_i = [repelem(tau_l,n/4) repelem(tau_h, n/4) ...
         repelem(tau_l,n/4) repelem(tau_h, n/4)]';

% draw v and s
s_i = zeros(n, 1); %normrnd(mu_s, sigma_s, n, 1);
v_i = normrnd(mu_v, sigma_v, n, 1);

% calc discrete choice obj function
u_i = p_i.*(v_i-tau_i);
yes = u_i >= 0;

dat = table(p_i, tau_i, s_i, v_i, u_i, yes);

% calculate empirical moments P(yes | tau, 
h = [zeros(4,1); ... % zeros for incentivized moments
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_l)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_l)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_h)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_h)); ...
     zeros(4,1) ]; % zeros for incentivized moments

W = diag([zeros(4,1); ones(4,1); zeros(4,1)]);


% define objective function
obj = @(theta) (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),theta(4),0,0,0)-h)' * ...
    W * ...
    (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),theta(4),0,0,0)-h);

% define initial parameter guesses
p_l0     = 0.005;
p_h0     = 0.01;
mu_v0    = 30;
sigma_v0 = 70;

options = optimset('TolFun', 1e-10);

% perform optimization
theta = fmincon(obj, [p_h0, p_l0, mu_v0, sigma_v0], [-1 1 0 0], 0);
disp(theta);

rng default % For reproducibility
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[p_l0,p_h0,mu_v0,sigma_v0],...
    'objective',obj,'lb',[0,0.0005,20,30],'ub',[1,0.5,50,80]);
theta = run(gs,problem);
disp(theta);

%% Question 2.1

% function calculates all moments analytically
% arguments: (tau_h, tau_l, p_h, p_l, mu_v, sigma_v, mu_s, sigma_s, inc)
m = calculate_moments(tau_h, tau_l, p_h, p_l, mu_v, sigma_v, ...
                   mu_s, sigma_s, inc);

% plot static analytical moments
figure;
bar(m(5:8));
set(gca,'xticklabel', ...
    {'$p_l$, $\tau_l$','$p_h$, $\tau_l$','$p_l$, $\tau_h$','$p_h$, $\tau_h$'}, ...
    'TickLabelInterpreter', 'latex');
title('Moments for Zero Incentive')

saveas(gcf,'part2_1.jpeg');
close all;

% redraw v and s
s_i = normrnd(mu_s, sigma_s, n, 1);
v_i = normrnd(mu_v, sigma_v, n, 1);

% calc discrete choice obj function
u_i = p_i.*(v_i-tau_i) + s_i;
yes = u_i >= 0;

dat = table(p_i, tau_i, s_i, v_i, u_i, yes);

% calculate empirical moments P(yes | tau, 
h = [zeros(4,1); ... % zeros for incentivized moments
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_l)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_l)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_h)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_h)); ...
     zeros(4,1) ]; % zeros for incentivized moments


% define objective function
obj = @(theta) (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),theta(4),theta(5),theta(6),0)-h)' * ...
    W * ...
    (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),theta(4),theta(5),theta(6),0)-h);

% define initial parameter guesses
p_l0     = 0.005;
p_h0     = 0.01;
mu_v0    = 30;
sigma_v0 = 70;
mu_s0    = 0.9;
sigma_s0 = 2.1;

% perform optimization
% theta = fmincon(obj, [p_h0, p_l0, mu_v0, sigma_v0, mu_s0, sigma_s0], ...
%     [-1 1 0 0 0 0], 0);
% 
% disp(theta);
% oh god we're not identified at all

rng default % For reproducibility
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[p_l0,p_h0,mu_v0,sigma_v0,mu_s0,sigma_s0],...
    'objective',obj,'lb',[0,0.0005,20,30,0.9,1],'ub',[1,0.5,50,80,3,5]);
theta = run(gs,problem);
disp(theta);

%% Question 2.2

% try fixing p_h and p_l, estimate mu and sigma for s and v
% define objective function
obj = @(theta) (calculate_moments(tau_h,tau_l,p_h,p_l,theta(1),theta(2),theta(3),theta(4),0)-h)' * ...
    (calculate_moments(tau_h,tau_l,p_h,p_l,theta(1),theta(2),theta(3),theta(4),0)-h);

% define initial parameter guesses
mu_v0    = 30;
sigma_v0 = 70;
mu_s0    = 1.1;
sigma_s0 = 2.1;

% perform optimization
rng default % For reproducibility
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[mu_v0,sigma_v0,mu_s0,sigma_s0],...
    'objective',obj,'lb',[29,45,0.9,1.9],'ub',[45,71,2,5]);
theta = run(gs,problem);

disp(theta);

% theta = fmincon(obj, [mu_v0, sigma_v0, mu_s0, sigma_s0]);
% disp(theta);

% try fixing p_h and p_l and mu and sigma for s estimate mu, sigma for v
% define objective function
obj = @(theta) (calculate_moments(tau_h,tau_l,p_h,p_l,theta(1),theta(2),1,2,0)-h)' * ...
    W * ...
    (calculate_moments(tau_h,tau_l,p_h,p_l,theta(1),theta(2),1,2,0)-h);

% define initial parameter guesses
mu_v0    = 30;
sigma_v0 = 70;
mu_s0    = 1;
sigma_s0 = 2;

% perform optimization
theta = fmincon(obj, [mu_v0, sigma_v0], [0 -1], 0);
disp(theta);

%% Question 3

dat.id = rand(size(dat.p_i));
sortrows(dat,["p_i", "tau_i", "id"]);

dat.inc_i = repmat([repelem(-inc, n/12)' ; repelem(0, n/12)'; repelem(inc, n/12)'],4,1);

% calc discrete choice obj function
dat.u_i = dat.p_i.*(dat.v_i-dat.tau_i) + dat.s_i + dat.inc_i;
dat.yes = dat.u_i >= 0;

% calculate empirical moments P(yes | tau, p, inc)
h = [mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_l & dat.inc_i==-inc)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_l & dat.inc_i==-inc)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_h & dat.inc_i==-inc)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_h & dat.inc_i==-inc)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_l & dat.inc_i==0)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_l & dat.inc_i==0)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_h & dat.inc_i==0)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_h & dat.inc_i==0)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_l & dat.inc_i==inc)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_l & dat.inc_i==inc)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_h & dat.inc_i==inc)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_h & dat.inc_i==inc));];


% try fixing p_h and p_l, estimate mu and sigma for s and v
% define objective function
obj = @(theta)(calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),...
               theta(4),theta(5),theta(6),0.5)-h)' * eye(12) * ...
              (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),...
              theta(4),theta(5),theta(6),0.5)-h);

% perform optimization
theta = fmincon(obj, [p_h0, p_l0, mu_v0, sigma_v0, mu_s0, sigma_s0], ...
    [-1 1 0 0 0 0], 0);
