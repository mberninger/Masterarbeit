function [ rmse ] = getRmse( x, xref)
%GETRMSE evaluates the root mean squared error
%   it is the square root of the mean squared error 

rmse = sqrt(getMse(x, xref));

end

