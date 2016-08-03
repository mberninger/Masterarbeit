function [ mseVolaKalmanOut, rmseVolaKalmanOut ] = getPredCoeffKalmanOut( uniqueDates, filteredDataCall, coeff, vola, k, l )
%GETPREDCOEFFKALMANOUT evaluates the coefficients for the linear model to evaluate
%the volatility surface using out-of-sample testing. 
%   Therefore the function getPredCoeffKalman is used to evaluate the
%   estimated coefficients of the subsample. Then the last coefficients are
%   used as the initial values and the constant values A, b, omega and
%   residualVola from the function getPredCoeffKalman are used to predict
%   one day ahead the estimated coefficients.
    % The output is the mean squared error of the actual volatility and the
    % estimated volatility for each day j.

mseVolaKalmanOut = zeros(k,1);
rmseVolaKalmanOut = zeros(k,1);
filteredDataCall.DayNb = [1:size(filteredDataCall,1)]';

for j=1:k
dayVectorStart = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(j),:);
dayVectorEnd = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(l-1+j),:);
dayVectorPred = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(l+j),:);

startOut = dayVectorStart(1);
stopOut = dayVectorEnd(end);
startPred = dayVectorPred(1);
stopPred = dayVectorPred(end);
% startDay = l+j;

model = [1,2,3,4,5];
% coeffOut = getCoeff(model, filteredDataCall(startOut:stopOut,:));
coeffOut = coeff(j:j+l-1,:);

% [predCoeffKalman,predEpsKalman,A,b,omega,residualVola] = getPredCoeffKalman(coeffOut,uniqueDates,filteredDataCall(startOut:stopOut,:),vola(startOut:stopOut,:));
[predCoeffKalman,~,A,b,~,~] = getPredCoeffKalman(coeffOut,uniqueDates,filteredDataCall(startOut:stopOut,:),vola(startOut:stopOut,:));


    %time update
    muOut = A * predCoeffKalman(end,:)' + b;
%     epsOut = A * predEpsKalman * A' + omega;
%     %measurement update
%     thisDate = uniqueDates(startDay);
%     [thisObs,thisObsSize] = getObs(thisDate,filteredDataCall);
%     H = [ones(thisObsSize,1), thisObs.Moneyness, thisObs.Moneyness.^2, thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, thisObs.Moneyness .* thisObs.TimeToMaturity];
%     v = thisObs.implVol - H*muOut;
%     R = cov(residualVola)*eye(thisObsSize);
%     tau = H*epsOut*H' + R;    
%     %Kalman gain:
%     K = epsOut * H'*tau^-1;
%     
%     muOut = muOut + K*v;
    muOut = muOut';

volaKalmanOut = evalVola(filteredDataCall(startPred:stopPred,:),muOut,model);

mseVolaKalmanOut(j) = getMse(filteredDataCall.implVol(startPred:stopPred,:),volaKalmanOut);
rmseVolaKalmanOut(j) = getRmse(filteredDataCall.implVol(startPred:stopPred,:),volaKalmanOut);

end
end

