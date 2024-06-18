classdef tExamples < matlab.unittest.TestCase
    %tExamples - Unit tests to check if export also can run the MLX
    %
    % Copyright 2023 The MathWorks, Inc.
    methods (TestClassSetup)
        function setupTempDir(testCase)

            import matlab.unittest.fixtures.TemporaryFolderFixture
            import matlab.unittest.fixtures.CurrentFolderFixture

            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
        end

        function ignoreWarning(testCase)
            import matlab.unittest.fixtures.SuppressedWarningsFixture

            % Ignore expected warnings
            testCase.applyFixture(...
                SuppressedWarningsFixture('vision:pointcloud:HGMACIssue'));
            testCase.applyFixture(...
                SuppressedWarningsFixture('MPC:nlmpcMultistage:warnJacError2D'));
            testCase.applyFixture(...
                SuppressedWarningsFixture('SystemBlock:MATLABSystem:ParameterCannotBeTunable'));
            testCase.applyFixture(...
                SuppressedWarningsFixture('SL_SERVICES:utils:MemoryAllocationError'));
        end
    end

    methods (Test)
        function runExample1(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('CreateRoutePlannerUsingDigitalElevationData.mlx',Format='m',Run=true));
            testCase.log(1,'Completed running CreateRoutePlannerUsingDigitalElevationData');
        end

        function runExample2(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('CreateTerrainAwareGlobalPlanners.mlx',Format='m',Run=true));
            testCase.log(1,'Completed running CreateTerrainAwareGlobalPlanners');
        end

        function runExample3(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('CreateLocalPlannerToNavigateGlobalPath.mlx',Format='m',Run=true));
            testCase.log(1,'Completed running CreateLocalPlannerToNavigateGlobalPath');
        end

        %function runExample4(testCase)

            %% export also can run the MLX
            %testCase.verifyWarningFree(@()export('ModelAndControlAutonomousHaulTruck.mlx',Format='m',Run=true));
            %testCase.log(1,'Completed running ModelAndControlAutonomousHaulTruck');
            
           % % Add teardown
          %  testCase.addTeardown(@()bdclose('all')); % For simulink model
         %   testCase.addTeardown(@()close('all')); % For the figures
        %end
    end
end
