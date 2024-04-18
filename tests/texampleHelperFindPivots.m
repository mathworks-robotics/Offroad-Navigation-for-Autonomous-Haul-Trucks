classdef texampleHelperFindPivots < matlab.unittest.TestCase
%texampleHelperFindPivots - Unit tests for exampleHelperFindPivots

% Copyright 2024 The MathWorks, Inc.

    properties(TestParameter)
        pStartPose = {[0 0 0], [1 1 pi],        [1.5 1.5 4.71], [2.25 2.25 7], [3.75 3.75 10]};
        pGoalPose = {[1 1 pi], [1.5 1.5 4.71],  [2.25 2.25 7], [3.75 3.75 10], [3.75 3.75 10].*1.5};
    end
    methods (Test, ParameterCombination = 'sequential')
        function findPivots(testCase, pStartPose, pGoalPose)
        % findPivots calculates the pivot points using Reeds Shepp and
        % compares it with the output from the helper function

            reedsConnObj = reedsSheppConnection;
            reedsConnObj.MinTurningRadius = 2;
            pathSegObj = connect(reedsConnObj,pStartPose,pGoalPose);
            interpPoints = pathSegObj{1}.interpolate;

            % Filter out non-directional change to just keep the pivot
            % points to match the actual results
            RSPivotPoints = [interpPoints(1,:); interpPoints(ischange(pathSegObj{1}.MotionDirections),:); interpPoints(end,:)];

            % Interpolate arc to generate reference path for
            % exampleHelperFindPivots helper function
            rPath = pathSegObj{1}.interpolate(0:0.1:pathSegObj{1}.Length);

            % Calculate pivotPoints and segment states from the helper
            % function
            pivotPoints = [];
            segmentsCombined = [];
            [segments,pivotIdx,nSeg] = exampleHelperFindPivots(rPath);
            pivotPoints = [pivotPoints;segments(1).States(pivotIdx(1),:)]; %#ok<*AGROW>
            segmentsCombined = segments(1).States(1,:);
            for j = 1:numel(pivotIdx)-1
                pivotPoints = [pivotPoints;segments(j).States(pivotIdx(j+1)-pivotIdx(j)+1,:)];
                segmentsCombined = [segmentsCombined;segments(j).States(2:end,:)];
            end

            % Verify output
            testCase.verifyEqual(pivotPoints,RSPivotPoints);
            testCase.verifyEqual(rPath(pivotIdx,:),RSPivotPoints);
            testCase.verifyEqual(segmentsCombined,rPath);
            testCase.verifyEqual(nSeg, numel(pivotIdx)-1);
        end

        function tolerance(testCase)
        % tolerance Test to validate if the tolerance angle is taking in to
        % effect and verifies if the number of segments is returned as
        % expected

            % Set viewPlot to true to plot the refPath used in this test
            viewPlot = false;

            % N is the number of points in each segment
            N = 100;

            % Create a circular reference path to use in the test
            circr = @(radius,rad_ang)  [radius*cos(rad_ang);  radius*sin(rad_ang)];
            r_angl = linspace(pi/4, 2*pi, N);
            radius = 15;
            xy_r = circr(radius,r_angl);
            circPath = xy_r';

            % Create another segment for directional change connected to
            % the end of the circular path
            newSeg_y = linspace(circPath(end,2), circPath(end,2)- 40, N);
            newSeg = [zeros(N,1)+circPath(end,1), newSeg_y'];
            
            % call the helper function with and without last few points in
            % the circular path to have success and failure cases
            refPath1 = [circPath(1:end,:); newSeg(2:end,:)];
            refPath2 = [circPath(1:end-7,:); newSeg(2:end,:)];
            [~,pivotIdx1,nSeg1] = exampleHelperFindPivots(refPath1); %#ok<ASGLU>
            [~,pivotIdx2,nSeg2] = exampleHelperFindPivots(refPath2); %#ok<ASGLU>
            
            % viewPlot Plots the reference path depending on the value set
            if viewPlot
                figure(1); %#ok<UNRCH>
                plot(refPath1(:,1), refPath1(:,2), 'bp');
                axis equal;
                hold on;
                plot(refPath1(pivotIdx1,1),refPath1(pivotIdx1,2), 'O');
                figure(2)
                plot(refPath2(:,1), refPath2(:,2), 'bp');
                axis equal;
                hold on;
                plot(refPath2(pivotIdx2,1),refPath2(pivotIdx2,2), 'O');
            end

            % Verify the number of segments and the tolerance angle impact
            testCase.verifyEqual(nSeg1,2);
            theta1 = headingFromXY([circPath(end-1,:);newSeg(2:3,:)]);
            testCase.verifyTrue(abs(robotics.internal.angdiff(theta1(1:2))) > pi-abs(pi/16));
            testCase.verifyEqual(nSeg2,1);
            theta2 = headingFromXY([circPath(end-7,:);newSeg(2:3,:)]);
            testCase.verifyFalse(abs(robotics.internal.angdiff(theta2(1:2))) > pi-abs(pi/16));
        end
    end
end