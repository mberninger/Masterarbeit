function [ mse ] = getMse( x, xref, n )
%GETMSE evaluates the mean squared error
%   Detailed explanation goes here

mse = 1/n *sum((xref-x).^2);

end

