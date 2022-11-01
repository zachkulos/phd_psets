%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Computational Problem Set, Theory of Income I
% Zachary Kuloszewski
%
% Last Edit Date: Nov 26, 2021
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set directories
clear; clc;
cd '/Users/zachkuloszewski/Desktop/Classes/Macro/Problem Sets/comp_ps';
addpath(genpath('figures'));

%% set parameter values
beta  = 0.99;
z     = 1;
alpha = 0.3;
delta = 0.1;

error_tol = 1e-5;

%% init state space grid
n = 500;
up_bound = (delta/z)^(1/(alpha-1));  % effective upper bound: 0 consumption
K        = linspace(0.1,up_bound,n);   % state space for k

%% iteration loop

% init error value
error = 1000;

% init loop counter
n_iter = 0;

% initial V function guess
V        = [];
V0       = zeros(1,n);
V(1,1:n) = 0;
V_old    = V(1,:);

while (error > error_tol) 

    % count number of iterations
    n_iter = n_iter+1; 
    
    % init objective, policy fn, and new value function objects
    obj   = nan(n,n);
    V_new = zeros(1,n);
    g = zeros(1,n);

    for i=1:n  %iterate through state space
        k = K(i);
        
        % identify indices of state space where ln() argument > 0
        inds = (K < z*k^alpha + (1-delta)*k);

        if sum(inds)>0
            obj(i,inds) = log(z*k^alpha + (1-delta)*k - K(inds)) + beta*V_old(inds); 
            V_new(i)    = max(obj(i,:));
            g(i) = K(obj(i,:)==V_new(i));
        end
        
    end

    % update value function, recalculate error
    V(n_iter,:) = V_new;
    error = max(abs(V_new - V_old));
    V_old = V_new;

end

disp(['Number of iterations: ' num2str(n_iter)]);

%% steady state results

% calc and display theoretical and numerical steady state Capital levels
k_ss_emp_2a = min(K(K==g));
k_ss_2a    = ((1-beta+beta*delta)/(beta*alpha*z)).^(1/(alpha-1)); 

disp('Part 2a, Beta = 0.99');
disp(['Numerical Approximation: k = ', num2str(k_ss_emp_2a)]);
disp(['Theoretical Value: k = ', num2str(k_ss_2a)]);

% empirical/theoretical steady state Consumption Values
cons_ss_emp = z*k_ss_emp_2a^alpha - delta*k_ss_emp_2a; % empirical
cons_ss     = z*k_ss_2a^alpha     - delta*k_ss_2a;     % theoretical

disp(['Numerical Approximation: c = ', num2str(cons_ss_emp)]);
disp(['Theoretical Value: c = ', num2str(cons_ss)]);

%% plot all iterations (part 2a, beta = 0.99)

% close all; 

% color gradient for plotting
colors = parula(n_iter);

% plot with all iterations
figure;
hold on;
plot(K,V0, 'Color','red')
xlabel('K');
ylabel('Value Function')
for i=1:n_iter
    plot(K,V(i,:), 'Color', colors(i,:))
end
title('All Iterations, Initial Guess V=0');
hold off;

saveas(gcf, 'figures/2a_i_all_iter.jpeg');


%% plot final iteration (part 2a, beta = 0.99)

figure;
plot(K,V(end,:));
xlabel('K');
ylabel('Value Function');
title('Final Value Function');
saveas(gcf, 'figures/2a_i_final.jpeg');

%% plot policy function (part 2a, beta = 0.99)

figure;
plot(K,[g;K]);
xlabel('K');
ylabel('Value Function');
title('Optimal Policy Function');
legend({'g(x) Policy Fn.', '45° Line'},'Location','Northwest')
legend box off

saveas(gcf, 'figures/2a_ii_policy_fn.jpeg');

% close all;

%% Part 2b, beta = 0.1

% init state space grid
n = 500;
up_bound = (delta/z)^(1/(alpha-1));  % effective upper bound: 0 consumption
K        = linspace(0.1,up_bound,n);   % state space for k

% reinitialize parameters
beta  = 0.10;
error = 99999;

% init loop counter
n_iter = 0;

% initial V function guess
V        = [];
V0       = zeros(1,n);
V(1,1:n) = 0;
V_old    = V(1,:);

%% value function iteration 

while (error > error_tol) 

    % count number of iterations
    n_iter = n_iter+1; 
    
    % init objective, policy fn, and new value function objects
    obj   = nan(n,n);
    V_new = zeros(1,n);
    g = zeros(1,n);

    for i=1:n  %iterate through state space
        k = K(i);
        
        % identify indices of state space where ln() argument > 0
        inds = (K < z*k^alpha + (1-delta)*k);

        if sum(inds)>0
            obj(i,inds) = log(z*k^alpha + (1-delta)*k - K(inds)) + beta*V_old(inds); 
            V_new(i)    = max(obj(i,:));
            g(i) = K(obj(i,:)==V_new(i));
        end
        
    end

    % update value function, recalculate error
    V(n_iter,:) = V_new;
    error = max(abs(V_new - V_old));
    V_old = V_new;

end

disp(['Number of iterations: ' num2str(n_iter)]);

%% steady state results

% calc and display theoretical and numerical steady state Capital levels
k_ss_emp_2b = min(K(K==g));
k_ss_2b     = ((1-beta+beta*delta)/(beta*alpha*z)).^(1/(alpha-1)); 

disp('Part 2b, Beta = 0.10');
disp(['Numerical Approximation: ', num2str(k_ss_emp_2b)]);
disp(['Theoretical Value: ', num2str(k_ss_2b)]);

% empirical/theoretical steady state Consumption Values
cons_ss_emp = z*k_ss_emp_2b^alpha - delta*k_ss_emp_2b; % empirical
cons_ss     = z*k_ss_2b^alpha     - delta*k_ss_2b;     % theoretical

% disp(['Numerical Approximation: c = ', num2str(cons_ss_emp)]);
% disp(['Theoretical Value: c = ', num2str(cons_ss)]);

%% plot all iterations (part 2b, beta = 0.10)

% close all; 

% color gradient for plotting
colors = parula(n_iter);

% plot with all iterations
figure;
hold on;
plot(K,V0, 'Color','red')
xlabel('K');
ylabel('Value Function')
for i=1:n_iter
    plot(K,V(i,:), 'Color', colors(i,:))
end
title('All Iterations, Initial Guess V=0');
hold off;

saveas(gcf, 'figures/2b_i_all_iter.jpeg');


%% plot final iteration (part 2b, beta = 0.10)

figure;
plot(K,V(end,:));
xlabel('K');
ylabel('Value Function');
title('Final Value Function');
saveas(gcf, 'figures/2b_i_final.jpeg');

%% plot policy function (part 2b, beta = 0.10)

figure;
plot(K,[g;K]);
xlabel('K');
ylabel('Value Function');
title('Optimal Policy Function');
legend({'g(x) Policy Fn.', '45° Line'},'Location','Northwest')
legend box off

saveas(gcf, 'figures/2b_ii_policy_fn.jpeg');

% close all;

%% part 2c, beta = 0.9, functional initial guess

% init state space grid
n = 500;
up_bound = (delta/z)^(1/(alpha-1));  % effective upper bound: 0 consumption
K        = linspace(0.1,up_bound,n);   % state space for k

% reinitialize parameters
beta  = 0.99;
error = 99999;

% init loop counter
n_iter = 0;

% init V matrix
V = [];

% functional guess for V
inds                = (z*K.^alpha-delta*K > 0);
V_old               = nan(1,n);
V_old(inds)         = log(z*K(inds).^alpha-delta*K(inds))/(1-beta);

V0 = V_old;

%% value function iteration 

while (error > error_tol) 

    % count number of iterations
    n_iter = n_iter+1; 
    
    % init objective, policy fn, and new value function objects
    obj   = nan(n,n);
    V_new = zeros(1,n);
    g = zeros(1,n);

    for i=1:n  %iterate through state space
        k = K(i);
        
        % identify indices of state space where ln() argument > 0
        inds = (K < z*k^alpha + (1-delta)*k);

        if sum(inds)>0
            obj(i,inds) = log(z*k^alpha + (1-delta)*k - K(inds)) + beta*V_old(inds); 
            V_new(i)    = max(obj(i,:));
            g(i) = K(obj(i,:)==V_new(i));
        end
        
    end

    % update value function, recalculate error
    V(n_iter,:) = V_new;
    error = max(abs(V_new - V_old));
    V_old = V_new;

end

disp(['Number of iterations: ' num2str(n_iter)]);

%% plot all iterations (part 2c, beta = 0.99)

% close all; 

% color gradient for plotting
colors = parula(n_iter);

% plot with all iterations
figure;
hold on;
plot(K,V0, 'Color','red')
xlabel('K');
ylabel('Value Function')
for i=1:n_iter
    plot(K,V(i,:), 'Color', colors(i,:))
end
title('All Iterations, Initial Guess V=0');
hold off;

saveas(gcf, 'figures/2c_i_all_iter.jpeg');


%% plot final iteration (part 2c, beta = 0.99)

figure;
plot(K,V(end,:));
xlabel('K');
ylabel('Value Function');
title('Final Value Function');
saveas(gcf, 'figures/2c_i_final.jpeg');

%% part 3c - comparative statics

% store policy rule for z=1
g_z1 = g;

% reinitialize parameters
beta  = 0.99;
error = 99999;
z     = 2;

% init state space grid
n = 500;
up_bound = (delta/z)^(1/(alpha-1));  % effective upper bound: 0 consumption
K        = linspace(0.1,up_bound,n);   % state space for k

% init loop counter
n_iter = 0;

% init V matrix
V = [];

% functional guess for V
inds                = (z*K.^alpha-delta*K > 0);
V_old               = nan(1,n);
V_old(inds)         = log(z*K(inds).^alpha-delta*K(inds))/(1-beta);

V0 = V_old;

%% value function iteration 

while (error > error_tol) 

    % count number of iterations
    n_iter = n_iter+1; 
    
    % init objective, policy fn, and new value function objects
    obj   = nan(n,n);
    V_new = zeros(1,n);
    g = zeros(1,n);

    for i=1:n  %iterate through state space
        k = K(i);
        
        % identify indices of state space where ln() argument > 0
        inds = (K < z*k^alpha + (1-delta)*k);

        if sum(inds)>0
            obj(i,inds) = log(z*k^alpha + (1-delta)*k - K(inds)) + beta*V_old(inds); 
            V_new(i)    = max(obj(i,:));
            g(i) = K(obj(i,:)==V_new(i));
        end
        
    end

    % update value function, recalculate error
    V(n_iter,:) = V_new;
    error = max(abs(V_new - V_old));
    V_old = V_new;

end

disp(['Number of iterations: ' num2str(n_iter)]);

%% z=2 results

% calc and display theoretical and numerical steady state Capital levels
k_ss_emp = min(K(K==g));
k_ss     = ((1-beta+beta*delta)/(beta*alpha*z)).^(1/(alpha-1)); 

disp('Part 3a, Beta = 0.99, z = 2');
disp(['Numerical Approximation: ', num2str(k_ss_emp)]);
disp(['Theoretical Value: ', num2str(k_ss)]);

% empirical/theoretical steady state Consumption Values
cons_ss_emp = z*k_ss_emp^alpha - delta*k_ss_emp; % empirical
cons_ss     = z*k_ss^alpha     - delta*k_ss;     % theoretical

disp(['Numerical Approximation: c = ', num2str(cons_ss_emp)]);
disp(['Theoretical Value: c = ', num2str(cons_ss)]);

% comparative plot
% close all;
figure;
plot(K,[g_z1;g;K])
legend({'Policy Fn. w. z=1', 'Policy Fn. w. z=2', '45 degree line'}, ...
    'Location','northwest')
legend box off
xlabel('K');
title('Comparing Policy Functions w/ Differing Productivity')
saveas(gcf, 'figures/3a_policy_fns.jpeg');

%% part 3b - impulse response function

irf    = zeros(1,30);
irf(1) = k_ss_emp_2a; % start in period 1 @ initial Kss
g0     = irf(1);

for i=2:30 
    [~,ind] = min(abs(K-g0));
    irf(i)  = g(ind);
    g0      = irf(i);
end

% plot ending IRF
% close all;
figure;
plot(0:29,irf);
title('Impule Response Function')
xlabel('Period')
xlim([0 29])

saveas(gcf, 'figures/3b_irf.jpeg');




