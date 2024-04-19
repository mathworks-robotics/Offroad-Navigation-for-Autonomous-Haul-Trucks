classdef tExamples < matlab.unittest.TestCase

    methods (TestClassSetup)
        function setupTempDir(testCase)

            import matlab.unittest.fixtures.TemporaryFolderFixture
            import matlab.unittest.fixtures.CurrentFolderFixture

            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
        end
    end

    methods (Test)
        function runExample1(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('CreateRoutePlannerUsingDigitalElevationData.mlx',Format='m',Run=true));
        end

        function runExample2(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('CreateTerrainAwareGlobalPlanners.mlx',Format='m',Run=true));
        end

        function runExample3(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('CreateLocalPlannerToNavigateGlobalPath.mlx',Format='m',Run=true));
        end

        function runExample4(testCase)

            % export also can run the MLX
            testCase.verifyWarningFree(@()export('ModelAndControlAutonomousHaulTruck.mlx',Format='m',Run=true));

            % Add teardown
            testCase.addTeardown(@()bdclose('all')); % For simulink model
            testCase.addTeardown(@()close('all')); % For the figures
        end
    end
end
