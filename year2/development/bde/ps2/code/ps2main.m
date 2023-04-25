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

% signal parameters
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

saveas(gcf,'output/part1_1.jpeg');
close all;

%% Question 1.3

%%% simulate data
n = 12000;
rng(2023);

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

% calculate empirical moments P(yes | tau, p)
h = [zeros(4,1); ... % zeros for incentivized moments
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_l)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_l)); ...
     mean(dat.yes(dat.p_i == p_l & dat.tau_i == tau_h)); ...
     mean(dat.yes(dat.p_i == p_h & dat.tau_i == tau_h)); ...
     zeros(4,1) ]; % zeros for incentivized moments

% init weighting matrix
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

% perform optimization
rng default % For reproducibility
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[p_l0,p_h0,mu_v0,sigma_v0],...
    'objective',obj,'lb',[0,0.0005,20,30],'ub',[1,0.5,50,80]);
theta = run(gs,problem);

disp('Question 1.3 Estimates')
disp(theta);

%% Question 2.1

% function calculates all moments analytically
% arguments: (tau_h, tau_l, p_h, p_l, mu_v, sigma_v, mu_s, sigma_s, inc)
m = calculate_moments(tau_h, tau_l, p_h, p_l, mu_v, sigma_v, ...
                   mu_s, sigma_s, inc);
m = [m calculate_moments(tau_h, tau_l, p_h, p_l, mu_v, sigma_v, ...
                   mu_s*2, sigma_s, inc)];
m = [m calculate_moments(tau_h, tau_l, p_h, p_l, mu_v, sigma_v, ...
                   mu_s, sigma_s*2, inc)];
m = [m calculate_moments(tau_h, tau_l, p_h, p_l, mu_v*2, sigma_v, ...
                   mu_s, sigma_s, inc)];
m = [m calculate_moments(tau_h, tau_l, p_h, p_l, mu_v, sigma_v*2, ...
                   mu_s, sigma_s, inc)];

% plot static analytical moments
figure;
bar(m(5:8,1:3));
set(gca,'xticklabel', ...
    {'$p_l$, $\tau_l$','$p_h$, $\tau_l$','$p_l$, $\tau_h$','$p_h$, $\tau_h$'}, ...
    'TickLabelInterpreter', 'latex');
title('Moments for Zero Incentive')
legend('Benchmark Values','\mu_s=2, \sigma_s=2','\mu_s=1, \sigma_s=4',...
    'Location','northeast');
legend box off
saveas(gcf,'output/part2_1.jpeg');
close all;

% redraw v and s
s_i = normrnd(mu_s, sigma_s, n, 1);
v_i = normrnd(mu_v, sigma_v, n, 1);

% calc discrete choice obj function
u_i = p_i.*(v_i-tau_i) + s_i;
yes = u_i >= 0;

dat = table(p_i, tau_i, s_i, v_i, u_i, yes);

% calculate empirical moments P(yes | tau, p)
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
rng default
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[p_l0,p_h0,mu_v0,sigma_v0,mu_s0,sigma_s0],...
    'objective',obj,'lb',[0,0.0005,20,30,0.9,1],'ub',[1,0.5,50,80,3,5]);
theta = run(gs,problem);

disp('Question 2.1 estimates:');
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

disp('Question 2.2.i estimates:');
disp(theta);

% try fixing p_h and p_l and mu and sigma for s estimate mu, sigma for v
% define objective function
obj = @(theta) (calculate_moments(tau_h,tau_l,p_h,p_l,theta(1),theta(2),1,2,0)-h)' * ...
    W * ...
    (calculate_moments(tau_h,tau_l,p_h,p_l,theta(1),theta(2),1,2,0)-h);

% define initial parameter guesses
mu_v0    = 30;
sigma_v0 = 70;

rng default % For reproducibility
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[mu_v0,sigma_v0],...
    'objective',obj,'lb',[20,30],'ub',[50,80]);
theta = run(gs,problem);

disp('Question 2.2.ii estimates:');
disp(theta);

%% Question 3

% plot static analytical moments
figure;
bar([m(5:8,1) m(1:4,1) m(9:end,1)]);
set(gca,'xticklabel', ...
    {'$p_l$, $\tau_l$','$p_h$, $\tau_l$','$p_l$, $\tau_h$','$p_h$, $\tau_h$'}, ...
    'TickLabelInterpreter', 'latex');
title('All Analytical Moments')
legend('No Incentive','Negative Incentive','Positive Incentive',...
    'Location','northeast');
legend box off
saveas(gcf,'output/part3.jpeg');
close all;

% more comparative statics
figure;
bar(m(5:8,1:5));
set(gca,'xticklabel', ...
    {'$p_l$, $\tau_l$','$p_h$, $\tau_l$','$p_l$, $\tau_h$','$p_h$, $\tau_h$'}, ...
    'TickLabelInterpreter', 'latex');
title('Moments for Zero Incentive')
legend('Benchmark Values','\mu_s=2, \sigma_s=2','\mu_s=1, \sigma_s=4',...
    '\mu_v=80','\sigma_v=100','Location','northeast');
legend box off
saveas(gcf,'output/part3_2.jpeg');
close all;

dat.id = rand(size(dat.p_i));
sortrows(dat,["p_i", "tau_i", "id"]);

% assign incentive treatments
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


% define objective function
obj = @(theta)(calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),...
               theta(4),theta(5),theta(6),0.5)-h)' * eye(12) * ...
              (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),...
              theta(4),theta(5),theta(6),0.5)-h);

% % perform optimization
rng default 
gs = GlobalSearch;
problem = createOptimProblem('fmincon','x0',[p_l0,p_h0,mu_v0,sigma_v0,mu_s0,sigma_s0],...
    'objective',obj,'lb',[0,0.0005,20,30,0.9,1],'ub',[1,0.5,50,80,3,5]);
theta = run(gs,problem);

disp('Question 3 estimates:');
disp(theta);


%% Question 4

rng(2023);

% generate data
n = 1000;

dat       = table;
dat.p_i   = [repelem(p_l, n/2) repelem(p_h, n/2)]';
dat.tau_i = [repelem(tau_l,n/4) repelem(tau_h, n/4) ...
             repelem(tau_l,n/4) repelem(tau_h, n/4)]';

% draw v and s
dat.s_i = normrnd(mu_s, sigma_s, n, 1);
dat.v_i = normrnd(mu_v, sigma_v, n, 1);

% assign incentive groups
dat.inc_i = nan(size(dat.p_i));
p_vec     = [p_l p_h];
tau_vec   = [tau_l tau_h];
inc_vec   = [-inc 0 inc];

for i=1:numel(p_vec)
    for j=1:numel(tau_vec)
        % find p and tau subgroup
        inds = (dat.p_i == p_vec(i) & dat.tau_i == tau_vec(j));
        % assign incentive (evenly with 1 remainder obs, assigned randomly)
        dat.inc_i(inds) = [repelem(-inc,floor(sum(inds)/3)) ...
                           repelem(0,floor(sum(inds)/3)) ...
                           repelem(inc,floor(sum(inds)/3)) ...
                           inc_vec(randi(3,1,1))];
    end
end

% calc discrete choice obj function
dat.u_i = dat.p_i.*(dat.v_i-dat.tau_i) + dat.s_i + dat.inc_i;
dat.yes = dat.u_i > 0;

dat.group = zeros(size(dat.p_i));
gp = 1;

% label groups
for i=1:numel(inc_vec)
    for j=1:numel(tau_vec)
        for k=1:numel(p_vec)
            dat.group(dat.p_i == p_vec(k) & dat.tau_i == tau_vec(j) ...
                & dat.inc_i == inc_vec(i)) = gp;
            gp = gp + 1;
        end
    end
end


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

% define objective function
obj = @(theta)(calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),...
               theta(4),theta(5),theta(6),0.5)-h)' * eye(12) * ...
              (calculate_moments(tau_h,tau_l,theta(1),theta(2),theta(3),...
              theta(4),theta(5),theta(6),0.5)-h);

% define initial parameter guesses
p_l0     = 0.005;
p_h0     = 0.01;
mu_v0    = 30;
sigma_v0 = 50;
mu_s0    = 0.9;
sigma_s0 = 2.1;

% perform optimization
rng default 
opts = optimoptions(@fmincon,'Algorithm','sqp');
gs = GlobalSearch('FunctionTolerance',1e-10);
problem = createOptimProblem('fmincon','x0',[p_l0,p_h0,mu_v0,sigma_v0,mu_s0,sigma_s0],...
    'objective',obj,'lb',[0,0.00005,20,40,0.9,1],'ub',[1,0.5,50,75,3,5], 'options', opts);
theta = run(gs,problem);

disp('Question 4 estimates:');
disp(theta);

% estimate variance covariance matrix at optimum
db = nan(size(h,1),size(theta,2));
permut_sz = 0.00001;

for i=1:numel(theta)
    th_p    = theta;
    th_m    = theta;
    th_p(i) = th_p(i) + permut_sz;
    th_m(i) = th_m(i) - permut_sz;
    db(:,i) = (calculate_moments(tau_h,tau_l,th_p(1),th_p(2),th_p(3),th_p(4),th_p(5),th_p(6),0.5) - ...
        calculate_moments(tau_h,tau_l,th_m(1),th_m(2),th_m(3),th_m(4),th_m(5),th_m(6),0.5)) ...
        ./ (2*permut_sz);
end

% calculate variance-covariance of moment vector
cov_m = diag(h .* (1-h));
% cov_m = zeros(numel(h));
% for i=1:numel(h)
%     for j=1:numel(h)
%         c = cov(dat.yes(dat.group==i), dat.yes(dat.group==j));
%         cov_m(i,j) = c(1,2);
%     end
% end

cv = (1/n) .* (inv(db' * db) * (db' * cov_m * db) * inv(db' * db));
se = sqrt(diag(cv));
disp(se);