%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Empirical Analysis II - Problem Set 6, Question 17
% Zachary Kuloszewski
% March 1, 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
close all;
warning  off;
cd /Users/zachkuloszewski/Desktop/Classes/Metrics/Q2/psets/ps6


%% part a

% init parameters
n_iter = 1000;
pi_bar = [0.2 0.5 0.8];
xi     = [1   0.5 0.25];

d_vec  = linspace(0,1,n_iter);
pi     = linspace(0,1,n_iter);

% init output storage
results = zeros(numel(pi_bar), numel(xi), numel(d_vec));

% loop through pi grid, xi grid
for i=1:numel(pi_bar)
    for j=1:numel(xi)
        
        % pi bar, xi parameters
        pi_i = pi_bar(i);
        xi_j = xi(j);
        
        % loop through d grid
        for d=1:n_iter
            % def obj function to minimize
            
            d_n = d_vec(d);
            obj = @(p) p*d_n + (1-p)*(1-d_n) + xi_j * p * (log(p) - log(pi_i)) + ...
                        xi_j * (1-p) * (log(1-p) - log (1-pi_i));
            
            [~,results(i,j,d)] = fminbnd(obj,0,1);
        end
    end
end

% plot results
figure; 

for i=1:numel(pi_bar)
    subplot(1,3,i);
    x1 = results(i,1,:);
    x2 = results(i,2,:);
    x3 = results(i,3,:);
    plot(d_vec,[x1(:) x2(:) x3(:)])

    title(['$\bar{\pi}$ = ' num2str(pi_bar(i))],'Interpreter','latex')
    xlabel('d');

    if i==2
        legend('$\xi = 1.0$', '$\xi = 0.5$','$\xi = 0.25$','Interpreter','latex', ...
            'Location','south')
        legend box off
    end
end
saveas(gcf,'Fig1.jpeg')

%% part b

% init output storage
results = zeros(numel(pi_bar), numel(xi), numel(d_vec));

% loop through pi grid, xi grid
for i=1:numel(pi_bar)
    for j=1:numel(xi)
        
        % pi bar, xi parameters
        pi_i = pi_bar(i);
        xi_j = xi(j);
        
        % loop through pi grid
        for p=1:n_iter
            % def obj function to minimize
            
            p_n = pi(p);
            obj = @(d) -1*(p_n*d + (1-p_n)*(1-d) + xi_j * p_n * (log(p_n) - log(pi_i)) + ...
                        xi_j * (1-p_n) * (log(1-p_n) - log (1-pi_i)));
            
            [~,val] = fminbnd(obj,0,1);
            results(i,j,p) = -val;
        end
    end
end

% plot results
figure; 

for i=1:numel(pi_bar)
    subplot(1,3,i);
    x1 = results(i,1,:);
    x2 = results(i,2,:);
    x3 = results(i,3,:);
    plot(d_vec,[x1(:) x2(:) x3(:)])

    title(['$\bar{\pi}$ = ' num2str(pi_bar(i))],'Interpreter','latex')
    xlabel('d');

    if i==2
        legend('$\xi = 1.0$', '$\xi = 0.5$','$\xi = 0.25$','Interpreter','latex', ...
            'Location','north')
        legend box off
    end
end
saveas(gcf,'Fig2.jpeg')
