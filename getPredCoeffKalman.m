function [mu,eps,A,b,omega,residualVola] = getPredCoeffKalman(coeff, uniqueDates, filteredDataCall, vola)
%GETPREDCOEFFKALMAN evaluates the coefficients for the linear model to evaluate
%the volatility surface. The state equation of the state space model
%is a VAR(1) model, the observation equation is a linear regression model
%to evaluate the implied volatility
    % The output of this function are the coefficients mu and the variance
    % eps of the last day

%First the parameters of the VAR(1) model are estimated
Spec = vgxset('n',6,'nAR',1, 'Constant',true);
EstSpec = vgxvarx(Spec,coeff);
predCoeff = evalCoeff(coeff,EstSpec.a,EstSpec.AR);

%Then the residuals of the two equtaions of the state space model are
%evaluated.
residualCoeff = coeff - predCoeff;
residualVola = filteredDataCall.implVol - vola;


%In order to use the Kalman filter, the initial values for the mean and
%variance of the coefficients are needed:
mu = zeros(size(coeff,2),size(coeff,1));
eps = cov(coeff(1,:))*eye(6);

%omega, the covariance of the residual of the state equation, and A, the
%parameter matrix of the observation equation, are constant:
omega = cov(residualCoeff); 
A = EstSpec.AR{1,1};
b = EstSpec.a;

for ii = 2:size(coeff,1)
    %time update:
    mu(:,ii) = A * mu(:,ii-1) + b;
    eps = A * eps * A' + omega;
    %measurement update:
    thisDate = uniqueDates(ii);
    [thisObs,thisObsSize] = getObs(thisDate,filteredDataCall);
    H = [ones(thisObsSize,1), thisObs.Moneyness, thisObs.Moneyness.^2, thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, thisObs.Moneyness .* thisObs.TimeToMaturity];
    v = thisObs.implVol - H*mu(:,ii);
    R = cov(residualVola)*eye(thisObsSize);
    tau = H*eps*H' + R;    
    %Kalman gain:
    K = eps * H'*tau^-1;
    
    mu(:,ii) = mu(:,ii) + K*v;
    eps = eps - K*tau*K';
end

mu = mu';

end

