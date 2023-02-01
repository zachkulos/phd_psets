function [g] = calculate_moments(tau_h, tau_l, p_h, ...
    p_l, mu_v, sigma_v, mu_s, sigma_s, inc)

    % this function takes in a vector of paramater value and returns a set
    % of analytically calculated moments

    % init output struct
    g = struct;

    % init vector of incentives
    inc_v = [-inc 0 inc];

    % sub matrix for each incentive scheme
    g = nan(12,1);

    for i=1:numel(inc_v)
        % calculate P(yes|parameters) for each incentive scheme
        % this calculates P(U < 0)
        g(4*(i-1)+1:4*i) =    ...
            [normcdf(p_l*tau_l-inc_v(i),mu_s + p_l*mu_v, sqrt(sigma_s^2 + p_l^2*sigma_v^2))  ... % P(yes|p_l, tau_l, inc)
             normcdf(p_h*tau_l-inc_v(i),mu_s + p_h*mu_v, sqrt(sigma_s^2 + p_h^2*sigma_v^2))  ... % P(yes|p_h, tau_l, inc)
             normcdf(p_l*tau_h-inc_v(i),mu_s + p_l*mu_v, sqrt(sigma_s^2 + p_l^2*sigma_v^2))  ... % P(yes|p_l, tau_h, inc)
             normcdf(p_h*tau_h-inc_v(i),mu_s + p_h*mu_v, sqrt(sigma_s^2 + p_h^2*sigma_v^2))];    % P(yes|p_h, tau_h, inc)

        % invert probability to calculate P(U > 0)
        g(4*(i-1)+1:4*i) = ones(4,1) - g(4*(i-1)+1:4*i);
    end
end

