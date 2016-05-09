function [ rmse ] = getRmse( x, xref)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

rmse = sqrt(getMse(x, xref));

end

