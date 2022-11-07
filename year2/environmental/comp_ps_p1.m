%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Computational Problem Set, Enviro I, Problem 1
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

%% Problem 1
% Solving the DDP by value function iteration; discrete state space.

%% part 1a - set up state space, parameters
N     = 501; 
S_tot = 1000;
r     = 0.05;

delta = 1/(1+r);
S     = linspace(0,S_tot,N);

%% part 1b - set up action space
A  = S;
nA = numel(A);

%% part 1c - define utility of extraction

% pick utility function of interest
u_fun_flag = 2; % choose 1 or 2

if u_fun_flag == 1
    u = @(x) 2*x.^0.5;
elseif u_fun_flag == 2
    u = @(x) 5*x-0.05*x.^2;
end

%% part 1d - define flow utility matrix
U = u(repmat(A,nA,1));

% def -inf upper triangular matrix
infs    = repmat(-Inf, N);
flow_UT = triu(infs,1);

% sum to get final flow utility matrix
U   = U + flow_UT;

%% part 1e - identify state in next period
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

%% part 1f - state transition matrix

T = nan(N,N*nA);
rows = 1:501;

for k=1:nA
    inds = rows - A(k)/2;
    inds(inds<=0) = 1;
    T(:,1+(k-1)*N:k*N) = sparse(rows(inds>0),inds(inds>0),ones(numel(inds(inds>0)),1),N,nA);
end

T = sparse(T);

%% part 1g - value funciton iteration

% init parameters
error     = 1e12;
error_tol = 1e-8;

% init value and optim choice
V_hist = nan(N,1000);
C_hist = nan(N,1000);

% iteration counter
n_iter = 0;

Vold = repelem(-Inf,N);

Vnext = nan(N,nA);

while error > error_tol
    
    % count number iterations
    n_iter = n_iter + 1;

    for k=1:nA %looping thru action space
        Vnext(:,k) = T(:,1+(k-1)*N:k*N)*U(:,k);
    end

    % grab optimized value and action column
    [V, C] = max(U + delta * Vnext,[],2);

    % store values and choices
    V_hist(:,n_iter) = V;
    C_hist(:,n_iter) = C;

    error = max(abs(V-Vold));

    Vold = V;
    U    = Vnext;

end

%% part 1h - find optimal transition matrix

% init matrix
Topt = zeros(N,nA);

for i=1:N
    Topt(i, C_hist(i,1)) = 1;
end

%% part 1i - simulate for t periods

t      = 80;
st     = S_tot; %init stock = 1000

% init storage for output
V_hist = nan(t,1);
C_hist = nan(t,1);
S_hist = nan(t,1);

for i=1:80

    st_ind = find(S == st); % find state index
    action = find(Topt(st_ind,:) == 1);
    
    st = st - A(action); % update stock

    S_hist(i) = st;
    C_hist(i) = A(action);
    V_hist(i) = u(A(action));
    
end

save(['part1_values_u' num2str(u_fun_flag)],"C_hist","V_hist","S_hist");

%% part 1j - plots

figure;
plot([V_hist, C_hist]);
legend("Price", "Extraction", Location="northeast");
legend box off
xlabel("Period")

if u_fun_flag == 1
    u_txt = "2\sqrt{y}$";
elseif u_fun_flag == 2
    u_txt = "5y - 0.05y^2$";
end

title(strcat("Extraction Level and Price Simulations, $u=", u_txt), ...
    'Interpreter','latex');

saveas(gcf, ['figures/part1j_u' num2str(u_fun_flag) '.png']);

