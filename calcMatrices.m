function outstr = calcMatrices(s1,s2,s3)
            
            % init J H and D
            J = eye(3);
            D = nan(3,length(s1.beta)-1);
            H = nan(3,1);

            % model z1
            H(1)    = s1.beta(1);
            D(1,:)  = s1.beta(2:end);

            % model z2
            J(2,1)  = -s2.beta(2)   ;
            H(2)    = s2.beta(1)+s2.beta(1)*H(1);
            D(2,:)  = s2.beta(3:end) + s2.beta(2)*(D(1,:)');

            % model z3
            J(3,1:2) = -s3.beta(2:3);
            H(3)     = s3.beta(1) - J(3,1:2)*H(1:2);
            D(3,:)   = s3.beta(4:end)'+sum(D(1:2,:).*s3.beta(2:3));

            % calculate Delta and F
            Delta    = diag([1/(s1.n*s1.zeta),1/(s2.n*s2.zeta),1/(s3.n*s3.zeta)]);
            F        = inv(J) * sqrt(Delta);
            
            % store results
            outstr.H = H;
            outstr.D = D;
            outstr.J = inv(J);
            outstr.F = F;
end