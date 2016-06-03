function [ filteredDataPut ] = getFilteredDataPut( data, timeToMaturityLowerBound, timeToMaturityUpperBound, mnyNessLowerBound, mnyNessUpperBound, optionPrice, implVolLowerBound, implVolUpperBound )
% This function filters the data and outputs the filtered data of the put
% options

%% extract put options from data
dataPut = data(data.IsCall == 0, :);

%% evaluate/load implied volatilities
load impliedVolaPut

% implVolPut = blsimpv(dataPut.DAX,dataPut.Strike,dataPut.EONIAmatched,dataPut.TimeToMaturity,dataPut.OptionPrice,[],[],[],{'Put'});

%% integrate implied volatilities into dataCall table
dataPut.implVol = implVolPut;


%% filtering of the data

%% 1. step: check upper and lower bounds of option prices to avoid arbitrage
% upper bound put: p < k (strike price) * exp(-r (interest rate)* t (time to maturity))
discountFactorPut = exp(-dataPut.EONIAmatched .* dataPut.TimeToMaturity);
putUpperBounds = dataPut.Strike .* discountFactorPut;
% lower bound put: max(k*exp(-rt)-s_t,0) < p
putLowerBounds = max(((dataPut.Strike .* discountFactorPut) - dataPut.DAX),0);

% store valid observations
validArbitrageIndsPut = putLowerBounds < dataPut.OptionPrice & ...
    dataPut.OptionPrice < putUpperBounds;

%% 2. step: check for negative time values and remove them (the time value is closer to zero, the closer the option is at the maturity date, but it is never negative)
intrinsicValPut = max((dataPut.Strike - dataPut.DAX),0);
timeValPut = dataPut.OptionPrice - intrinsicValPut;
validTimeValIndsPut = timeValPut > 0;

%% 3. step: check time to maturity, it should be between 20 and 510 days
maturityInDaysPut = dataPut.TimeToMaturity .* 255;
validMaturityIndsPut = timeToMaturityLowerBound <= maturityInDaysPut & maturityInDaysPut <= timeToMaturityUpperBound;

%% 4. step: evaluate and check moneyness, it should be between 0.8 and 1.2
mnyNessPut = dataPut.Strike ./ dataPut.DAX;
validMnyNessIndsPut = mnyNessLowerBound <= mnyNessPut & mnyNessPut <= mnyNessUpperBound;

%% 5. step: check option price, it should be bigger than 5 
validPriceIndsPut = dataPut.OptionPrice >= optionPrice;

%% 6. step: check implied volatilities, it should be between 5 and 50 percent
validImplVolaIndsPut = implVolLowerBound <= dataPut.implVol & dataPut.implVol <= implVolUpperBound;

%% integrate moneyness into dataPut table
dataPut.Moneyness = mnyNessPut;

%% apply all filters
validIndsPut = validArbitrageIndsPut & validTimeValIndsPut & validMaturityIndsPut & ...
    validMnyNessIndsPut & validPriceIndsPut & validImplVolaIndsPut;

filteredDataPut = dataPut(validIndsPut, :);

end