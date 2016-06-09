function [  ] = plotCoeffDensity( coeff )
%PLOTCOEFFDENSITY plots the histogram of the coefficient and the normal pdf
%in one graph

nbins=30;
histogram(coeff,nbins,'Normalization','pdf');
hold on
grid on 
grid minor
mu = mean(coeff);
sigma = std(coeff);
y =mu-4*sigma:0.001:mu+4*sigma;
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(y,f,'LineWidth',1.5)
hold off

end

