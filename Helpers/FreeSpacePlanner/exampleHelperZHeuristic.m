function cost = exampleHelperZHeuristic(motionSegment, costMap,weight)
%exampleHelperZHeuristic Ignore gradients, include height in cost
%

% Copyright 2023-2024 The MathWorks, Inc.

    states = nav.algs.hybridAStar.motionPrimitivesInterpolate(motionSegment, 1); 

    cost = nan(size(states,3),1); 

    % Get Z layer
    zMap = costMap.getLayer("Z"); 

    for i=1:size(states,3) 

        XYPoints = squeeze(states(:,1:2,i)); 

        % Get height difference 
        Z = zMap.getMapData(XYPoints); 

        % Calculate cost 
        cost(i) = sum(sqrt(sum([XYPoints(2:end,:)-XYPoints(1:end-1,:) weight*(Z(2:end)-Z(1:end-1))].^2,2))); 
    end 

    % Add this custom to plannerHybridAStar standard cost  
    cost = cost + nav.algs.hybridAStar.transitionCost(motionSegment); 
end