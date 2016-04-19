%% Here alternative models are tested for goodness of fit out of sample

%% MODEL FROM MAIN:
%% find coefficients for model; used modell: implied volatility = a + b*moneyness + c*moneyness^2 + d*timeToMaturity + e*moneyness*timeToMaturity
nDates = size(uniqueDates, 1)/2;
coeff = zeros(5, nDates);
for ii = 1:nDates
%       moneyness = filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1);
%       moneyness_2 = moneyness.^2;
%       time = filteredDataCall.TimeToMaturity(dataPerDay(i):dataPerDay(i+1)-1);
%       data_money = [moneyness, moneyness_2, time, time.*moneyness];
%       iVol = filteredDataCall.implVol(dataPerDay(i):dataPerDay(i+1)-1);

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(ii):dayChanges(ii+1)-1, :);
    
    % get design matrix
    Xmatrix = [thisObs.Moneyness, thisObs.Moneyness.^2, ...
        thisObs.TimeToMaturity, ...
        thisObs.TimeToMaturity .* thisObs.Moneyness];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix, thisObs.implVol);
    coeff(:,ii) = table2array(mdl.Coefficients(:,1));

end
clear ii;
coeff = coeff.';

%%
vola = zeros(nDates,1);
for i = 1:length(coeff)
    for j = dayChanges(i+nDates):dayChanges(i+1+nDates)
        M = filteredDataCall.Moneyness(j-1);
        T = filteredDataCall.TimeToMaturity(j-1);
        vola(i) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*M.^2 + coeff(i,4).*T + coeff(i,5).*T.*M;
    end
end

clear M;
clear T;
clear i;
clear j;
%%
SSR = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-vola).^2);
SST = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-mean(filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1))).^2);
R = 1-SSR/SST;
gnOfFitOutOfSample = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1),'MSE');



%% MODEL_1:
%% Alternative model 1: model_1 = a + b*moneyness + c*timeToMaturity

nDates = size(uniqueDates, 1)/2;
coeff = zeros(3, nDates);
for i = 1:nDates

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix_1 = [thisObs.Moneyness, thisObs.TimeToMaturity];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix_1, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end
clear i;
coeff = coeff.';

%%
vola = zeros(nDates,1);
for i = 1:length(coeff)
    for j = dayChanges(i+nDates):dayChanges(i+1+nDates)
        M = filteredDataCall.Moneyness(j-1);
        T = filteredDataCall.TimeToMaturity(j-1);
        vola(i) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*T;
    end
end

clear M;
clear T;
clear i;
clear j;
%%
SSR = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-vola).^2);
SST = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-mean(filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1))).^2);
R_1 = 1-SSR/SST;
gnOfFitOutOfSample_1 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1),'MSE');
% gnOfFit4_1 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:1908,1),'NRMSE');
% gnOfFit5_1 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:1908,1),'NMSE');


%% MODEL_2
%% alternative model 2: model_2 = a + b*moneyness + c*moneyness^2

nDates = size(uniqueDates, 1)/2;
coeff = zeros(3, nDates);
for i = 1:nDates

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix_1 = [thisObs.Moneyness, thisObs.Moneyness.^2];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix_1, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end
clear i;
coeff = coeff.';

%%
vola = zeros(nDates,1);
for i = 1:length(coeff)
    for j = dayChanges(i+nDates):dayChanges(i+1+nDates)
        M = filteredDataCall.Moneyness(j-1);
        T = filteredDataCall.TimeToMaturity(j-1);
        vola(i) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*M.^2;
    end
end

clear M;
clear T;
clear i;
clear j;
%%
SSR = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-vola).^2);
SST = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-mean(filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1))).^2);
R_2 = 1-SSR/SST;
gnOfFitOutOfSample_2 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1),'MSE');
% gnOfFit4_2 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:1908,1),'NRMSE');
% gnOfFit5_2 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:1908,1),'NMSE');


%% MODEL_3
%% alternative model 3: model_3 = a + b*moneyness + c*moneyness^2 + d*timeToMaturity + e*timeToMaturity^2 + f*timeToMaturity*Moneyness

nDates = size(uniqueDates, 1)/2;
coeff = zeros(6, nDates);
for i = 1:nDates

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix_1 = [thisObs.Moneyness, thisObs.Moneyness.^2, thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, thisObs.TimeToMaturity.*thisObs.Moneyness];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix_1, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end
clear i;
coeff = coeff.';

%%
vola = zeros(nDates,1);
for i = 1:length(coeff)
    for j = dayChanges(i+nDates):dayChanges(i+1+nDates)
        M = filteredDataCall.Moneyness(j-1);
        T = filteredDataCall.TimeToMaturity(j-1);
        vola(i) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*M.^2 + coeff(i,4).*T + coeff(i,5).*T.^2 + coeff(i,6).*T.*M;
    end
end

clear M;
clear T;
clear i;
clear j;
%%
SSR = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-vola).^2);
SST = sum((filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1)-mean(filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1))).^2);
R_3 = 1-SSR/SST;
gnOfFitOutOfSample_3 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1),'MSE');
% gnOfFit4_3 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1),'NRMSE');
% gnOfFit5_3 = goodnessOfFit(vola,filteredDataCall.implVol(nDates+1:size(uniqueDates, 1),1),'NMSE');





%% old attempt
% %% fit VAR model
% Spec = vgxset('n',5,'nAR',1, 'Constant',true);
% EstSpec = vgxvarx(Spec,coeff);
% % simulate coeff for 100 obs
% H = vgxsim(EstSpec,100);
% 
% %%
% vola = zeros(100,1);
% for i = 1:length(H)
%     for j = dataPerDay(i-1+954):dataPerDay(i+954)
%         M = filteredDataCall.Moneyness(j);
%         T = filteredDataCall.TimeToMaturity(j);
%         vola(i) = H(i,1) + H(i,2).*M + H(i,3).*M.^2 + H(i,4).*T + H(i,5).*T.*M;
%     end
% end
% clear i;
% clear j;
% clear M;
% clear T;
% 
% %% plot coefficients of model
% plot(uniqueDates(1:954), coeff)
% grid on
% grid minor
% datetick 'x'
% legend('a','b','c','d','e')
% title('Model coefficients')
% % TODO: find suitable names for coefficients
% 
% %% 
% 
% 
