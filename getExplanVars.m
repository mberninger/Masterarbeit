function [ thisModelExplanVars ] = getExplanVars( Var1, Var2, chosenModel )
%GETEXPLANVAR evaluates the explanatory variables for the chosen model
%   The five possible explanatory variables are stored in the variable
%   allExplanVars, then only the ones needed for the chosen model are taken
%   in the variable thisMOdelExplanVars

    % get all possible explanatory variables
    allExplanVars = [Var1, Var1.^2, Var2, Var2.^2, Var1.*Var2];
    % get required explanatory variables only
    thisModelExplanVars = allExplanVars(:, chosenModel);

end

