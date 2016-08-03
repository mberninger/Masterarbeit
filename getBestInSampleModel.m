function [ inSampleTesting ] = getBestInSampleModel( filteredData, allModels, modelAIC )
%GETBESTINSAMPLEMODEL evaluates the best model in-sample for fitting the
%implied volatility surfaces for every day
%   Five different models are compared (allModels)
%   The output is a table with the mean of R², the mean of
%   adj R², MSE, RMSE and the mean of the AIC

a = allModels(1,:)>0;
    model1 = allModels(1,a);
[coeff1, rsquared1] = getCoeff(model1, filteredData);
    
    a = allModels(2,:)>0;
    model2 = allModels(2,a);
[coeff2, rsquared2] = getCoeff(model2, filteredData);

    a = allModels(3,:)>0;
    model3 = allModels(3,a);
[coeff3, rsquared3] = getCoeff(model3, filteredData);

    a = allModels(4,:)>0;
    model4 = allModels(4,a);
[coeff4, rsquared4] = getCoeff(model4, filteredData);

a = allModels(5,:)>0;
    model5 = allModels(5,a);
[coeff5, rsquared5] = getCoeff(model5, filteredData);

vola1 = evalVola(filteredData, coeff1, model1 );
mse1 = getMse(vola1,filteredData.implVol);
rmse1 = getRmse(vola1,filteredData.implVol);
vola2 = evalVola(filteredData, coeff2, model2 );
mse2 = getMse(vola2,filteredData.implVol);
rmse2 = getRmse(vola2,filteredData.implVol);
vola3 = evalVola(filteredData, coeff3, model3 );
mse3 = getMse(vola3,filteredData.implVol);
rmse3 = getRmse(vola3,filteredData.implVol);
vola4 = evalVola(filteredData, coeff4, model4 );
mse4 = getMse(vola4,filteredData.implVol);
rmse4 = getRmse(vola4,filteredData.implVol);
vola5 = evalVola(filteredData, coeff5, model5 );
mse5 = getMse(vola5,filteredData.implVol);
rmse5 = getRmse(vola5,filteredData.implVol);

model1Testing = mean(rsquared1)';
model2Testing = mean(rsquared2)';
model3Testing = mean(rsquared3)';
model4Testing = mean(rsquared4)';
model5Testing = mean(rsquared5)';

inSampleTesting1 = [model1Testing(1,1), model1Testing(2,1), mse1, rmse1, mean(modelAIC(:,1))]';
inSampleTesting2 = [model2Testing(1,1), model2Testing(2,1), mse2, rmse2, mean(modelAIC(:,2))]';
inSampleTesting3 = [model3Testing(1,1), model3Testing(2,1), mse3, rmse3, mean(modelAIC(:,3))]';
inSampleTesting4 = [model4Testing(1,1), model4Testing(2,1), mse4, rmse4, mean(modelAIC(:,4))]';
inSampleTesting5 = [model5Testing(1,1), model5Testing(2,1), mse5, rmse5, mean(modelAIC(:,5))]';

inSampleTesting = [inSampleTesting1, inSampleTesting2, inSampleTesting3, inSampleTesting4, inSampleTesting5];
inSampleTesting = table(inSampleTesting(:,1),inSampleTesting(:,2),inSampleTesting(:,3),inSampleTesting(:,4),inSampleTesting(:,5),'VariableNames',{'Model1','Model2','Model3','Model4', 'Model5'},'RowNames',{'R^2';'AdjR^2';'MSE';'RMSE';'AIC'});


end

