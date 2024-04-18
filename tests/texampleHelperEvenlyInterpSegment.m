classdef texampleHelperEvenlyInterpSegment < matlab.unittest.TestCase
%texampleHelperEvenlyInterpSegment - Unit tests for exampleHelperEvenlyInterpSegment

% Copyright 2024 The MathWorks, Inc.

    methods (Test, ParameterCombination = 'sequential')
        function interpolate(testCase)
        % interpolate Test to verify if the example helper function
        % exampleHelperEvenlyInterpSegment interpolates the refPath as
        % expected

            viewPlot = false;
            N = 91;
            % Circle Function For Angles In Radians
            circr = @(radius,rad_ang)  [radius*cos(rad_ang);  radius*sin(rad_ang)];
            r_angl = linspace(2*pi-6, 2*pi, N);
            radius = 15;
            xy_r = circr(radius,r_angl);
            circPath = xy_r';            
            heading = pi/2 + r_angl';

            % View the ref path created and the heading angle as needed
            if viewPlot
                figure(1);
                plot(circPath(:,1), circPath(:,2), 'bp');
                axis equal;
                quiver(circPath(:,1), circPath(:,2), cos(heading), sin(heading2), 0.2)
            end

            % Call the helper function using the ref path created
            inPath = [circPath, heading];
            interPath = exampleHelperEvenlyInterpSegment(inPath, 1,1);

            % Verify the distance between each interpolated points are the
            % same in both cases.
            expDist = sqrt(sum(abs(diff( inPath(:,1:2))).^2,2));
            actDist = sqrt(sum(abs(diff( interPath(:,1:2))).^2,2));
            testCase.verifyEqual(actDist,expDist, 'AbsTol',sqrt(eps));

            % Verify the arc length between each interpolated points are the
            % same in both cases.
            expArcLen = diff(inPath(:,3))*radius;
            actArcLen = diff(interPath(:,3))*radius;
            testCase.verifyEqual(actArcLen,expArcLen, 'AbsTol',sqrt(eps));

            % Change the number of input values to make sure the helper function output
            % only depends on vNominal and timestep
            r_angl = linspace(2*pi-6, 2*pi, 200);
            xy_r = circr(radius,r_angl);
            circPath = xy_r';
            heading = pi/2 + r_angl';
            inPath2 = [circPath, heading];

            % Call the function with new set of inputs
            interPath2 = exampleHelperEvenlyInterpSegment(inPath2, 1,1);

            % Verify if interPath and interPath2 are equal.
            testCase.verifyEqual(interPath2, interPath2);

            % Create a new segment from the end of circular path created
            newSeg_y = linspace(circPath(end,2), circPath(end,2)- 90, N);
            newSeg = [zeros(N,1)+circPath(end,1), newSeg_y',zeros(N,1)-pi/2];

            % Connect the new segment created with the circular path and
            % call the helper function to genrate the evenly separated
            % interpolated points
            refPath = [inPath(1:end,:); newSeg(2:end,:)];
            interPath3 = exampleHelperEvenlyInterpSegment(refPath, 1,1);

            % Verify the refPath and interpolated points
            testCase.verifyEqual(refPath(:,1:2), interPath3(:,1:2), 'AbsTol',sqrt(eps));
        end
    end
end