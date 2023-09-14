function costValues = exampleHelperGradient2Cost(maxSlope, gradientValues)
%exampleHelperGradient2Cost Converts slope values to cost

    validateattributes(maxSlope,{'numeric'},{'scalar','positive','finite'});
    
    % Normalize slopes using max slope threshold
    costValues = abs(gradientValues)/maxSlope;

    % Slopes which exceed this value increase exponentially
    m = costValues > 1;
    costValues(m) = exp(costValues(m)-1);
end