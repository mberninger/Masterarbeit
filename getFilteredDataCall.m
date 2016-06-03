function [ filteredDataCall ] = getFilteredDataCall( data, timeToMaturityLowerBound, timeToMaturityUpperBound, mnyNessLowerBound, mnyNessUpperBound, optionPrice, implVolLowerBound, implVolUpperBound )
% This function filters the data and outputs the filtered data of the call
% options

%% extract call options from data
dataCall = data(data.IsCall == 1, :);

%% evaluate/load implied volatilities
load impliedVolaCall

% implVolCall = blsimpv(dataCall.DAX,dataCall.Strike,dataCall.EONIAmatched,dataCall.TimeToMaturity,dataCall.OptionPrice,[],[],[],{'Call'});

%% integrate implied volatilities into dataCall table

dataCall.implVol = implVolCall;

%% filtering of the data

%% 1. step: check upper and lower bounds of option prices to avoid arbitrage
% upper bound call: p (option price) < s_t (underlying)
callUpperBounds = dataCall.DAX;
% lower bound call: max(s_t-k*exp(-rt),0) < p
discountFactor = exp(-dataCall.EONIAmatched .* dataCall.TimeToMaturity);
callLowerBounds = max((dataCall.DAX - (dataCall.Strike .* discountFactor)), 0);

% store valid observations
validArbitrageInds = callLowerBounds < dataCall.OptionPrice & ...
    dataCall.OptionPrice < callUpperBounds ;

%% 2. step: check for negative time values and remove them (the time value is closer to zero, the closer the option is at the maturity date, but it is never negative)

intrinsicVal = max((dataCall.DAX - dataCall.Strike), 0);
timeVal = dataCall.OptionPrice - intrinsicVal;
validTimeValInds = timeVal > 0;

%% 3. step: check time to maturity, it should be between 20 and 510 days
maturityInDays = dataCall.TimeToMaturity .* 255;
validMaturityInds = timeToMaturityLowerBound <= maturityInDays & maturityInDays <= timeToMaturityUpperBound;

%% 4. step:  evaluate and check moneyness, it should be between 0.8 and 1.2 
mnyNess = dataCall.Strike ./ dataCall.DAX;
validMnyNessInds = mnyNessLowerBound <= mnyNess & mnyNess <= mnyNessUpperBound;

%% 5. step: check option price, it should be bigger than 5 
validPriceInds = dataCall.OptionPrice >= optionPrice;

%% 6. step: check implied volatilities, it should be between 5 and 50 percent
validImplVolaInds = implVolLowerBound <= dataCall.implVol & dataCall.implVol <= implVolUpperBound;

%% integrate moneyness into dataCall table
dataCall.Moneyness = mnyNess;

% apply all filters
validInds = validArbitrageInds & validTimeValInds & validMaturityInds & ...
    validMnyNessInds & validPriceInds & validImplVolaInds;

filteredDataCall = dataCall(validInds, :);

end

