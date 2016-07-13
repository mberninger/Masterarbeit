function [ mu ] = kalmanPred( coeffKalmanOut, epsOut, coeffOut, uniqueDates, filteredDataCall, model, startOut, stopOut )
%kalmanPred predicts the coefficients for the linear model to evaluate the
%volatility one day ahead. This function is used for testing the Kalman
%filter out-of-sample.

%find parameter for VAR(1) model
Spec = vgxset('n',6,'nAR',1, 'Constant',true);
EstSpec1 = vgxvarx(Spec,coeffOut);
estParam1 = evalCoeffVar(coeffOut,EstSpec1.a,EstSpec1.AR);

volaOut = evalVola(filteredDataCall(startOut:stopOut,:),coeffOut,model);

residualCoeff = coeffOut - estParam1;
residualVola = filteredDataCall.implVol(startOut:stopOut,:) - volaOut;

A = EstSpec1.AR{1,1};
omega = cov(residualCoeff);

    %time update
    mu = A * coeffKalmanOut(end,:)' + EstSpec1.a;
    epsOut = A * epsOut * A' + omega;
    %measurement update
    thisDate = uniqueDates(size(coeffOut,1)+1);
    [thisObs,thisObsSize] = getObs(thisDate,filteredDataCall);
    H = [ones(thisObsSize,1), thisObs.Moneyness, thisObs.Moneyness.^2, thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, thisObs.Moneyness .* thisObs.TimeToMaturity];
    v = thisObs.implVol - H*mu;
    R = cov(residualVola)*eye(thisObsSize);
    tau = H*epsOut*H' + R;    
    %Kalman gain:
    K = epsOut * H'*tau^-1;
    
    mu = mu + K*v;
    mu = mu';

end

