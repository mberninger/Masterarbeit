function [ mse ] = getMse( x, xref)
%GETMSE evaluates the mean squared error
%   Detailed explanation goes here

mse = mean((xref-x).^2);

end

