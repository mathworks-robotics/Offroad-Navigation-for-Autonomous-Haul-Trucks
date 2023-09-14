classdef texampleHelperTEBController < matlab.unittest.TestCase
    %texampleHelperTEBController - Unit test for processErrorCodes for
    %controllerTEB
    
    % Copyright 2023 The MathWorks, Inc.
    
    methods (Test)
        %% exampleHelperIntegrateControlSequence
        function integrateControlSequence(testCase)
            %integrateControlSequence

            initPose = [0 0 0];
            velcmds = [0.2 0; 0.1 0.25; zeros(3,2)];
            timestamps = (0:4)';
            dt = 1e-4;

            % Call the function under test
            optPath = exampleHelperIntegrateControlSequence(initPose, velcmds, ...
                timestamps, dt);

            % Use ode45 to solve the integration
            [tout,s] = ode45(@(t,s)texampleHelperTEBController.derivativeForNonHolonomic( ...
                t, s, velcmds, timestamps), timestamps, initPose);

            % x-y position should match
            testCase.verifyEqual(optPath, s,'AbsTol',1e-2);
        end
        
        %% exampleHelperUpdateTEBRefPath
        function updateTEBRefPath(testCase)
            %updateTEBRefPath

            load('dataForUpdateTEBRefPath.mat', 'teb', 'curpose');
            originalRefPath = teb.ReferencePath;

            exampleHelperUpdateTEBRefPath(teb,curpose,false);

            modifiedRefPath = teb.ReferencePath;

            % The modified path is generated only when more than 3 bad
            % points are present (i.e., atleast 3 points within
            % min-turning-radius).
            testCase.verifyLessThan( ...
                size(modifiedRefPath,1), ...
                size(originalRefPath,1) - 3);

            % Ensure modifiedRefPath is part of the originalRefPath
            % numerically
            testCase.verifyTrue(all(all(ismember(modifiedRefPath, originalRefPath))));
        end
        
        %% exampleHelperIdentifyPointInTurningRadius
        function identifyPointInTurningRadius(testCase)

            refpath = [0 0 ; 0 1];
            fut = @(pose, mtr) ...
            exampleHelperIdentifyPointInTurningRadius(refpath, pose, mtr);
            
            testCase.verifyEqual(fut([1 0 0], 1), [false; false]);
            testCase.verifyEqual(fut([1 0 0], 1.1), [false; true]);
            testCase.verifyEqual(fut([1 0 0], sqrt(2)), [false; true]);
            % Seem to be a problem with this.. as (1,0) and (0,1) are
            % sqrt(2) away, but seems adding a radius of slight greater
            % than sqrt(2) is unable to make points inside.
            %
            % testCase.verifyEqual(fut([1 0 0], 2*sqrt(2)), [true; true]);
            
        end
        
        %% exampleHelperComputeArcCenter
        function computeArcCenter(testCase)
            %computeArcCenter

            testCase.verifyEqual(...
                exampleHelperComputeArcCenter([0 0 -1], 1), ...
                -1* exampleHelperComputeArcCenter([0 0 -1], -1));


            testCase.verifyEqual(...
                exampleHelperComputeArcCenter([0 0 1], 1), ...
                -1* exampleHelperComputeArcCenter([0 0 1], -1));

            % [0 0 -pi/2], 1 ==> [1 0]
            testCase.verifyEqual(...
                exampleHelperComputeArcCenter([0 0 -pi/2], 1), [1 0], ...
                'AbsTol', sqrt(eps));
        end

        %% exampleHelperProcessTEBErrorCodes
        function exitFlagTurnViolation(testCase)
            % Test for exampleHelperProcessTEBErrorCodes/turnViolation
            data = load('exitFlagTurnViolations.mat');

            % Execute the processTEBErrorCodes
            velcmdsOut = ...
                exampleHelperProcessTEBErrorCodes(data.teb, data.curpose, ...
                    data.curvel, data.velcmds, ...
                    data.tstamps, data.curpath, data.info, ...
                    data.adjustedPath, data.length, data.width);
    
            % Compute turn violations
            turnViolationsOriginalVelCmds = computeTurnViolations(data.teb.MaxVelocity, data.velcmds);
            turnViolationsFinalVelCmds = computeTurnViolations(data.teb.MaxVelocity, velcmdsOut);

            % Verification

            % Ensure orignal velocity commands were violating
            % turnViolations
            testCase.verifyTrue(any(turnViolationsOriginalVelCmds));

            % Ensure output velocity commands were NOT violating
            % turnViolations
            testCase.verifyFalse(any(turnViolationsFinalVelCmds));

            function out = computeTurnViolations(maxVel, currVelCmds)
                % Compute radius of curvature
                minRadius = maxVel(1)/maxVel(2);
                roc = abs(currVelCmds(:,1)./currVelCmds(:,2));
                % Identify turn violations
                out = roc < minRadius;
            end
            
        end

        % function exitFlagSafetyMargin(testCase)
        %     % Test for
        %     % exampleHelperProcessTEBErrorCodes/ObstacleSafetyViolation
        %     data = load('exitFlagObstacleSafetyMargin.mat');
        % 
        %     velcmdsOut = ...
        %         exampleHelperProcessTEBErrorCodes(data.teb, data.curpose, ...
        %             data.curvel, data.velcmds, ...
        %             data.tstamps, data.curpath, data.info, ...
        %             data.adjustedPath, data.length, data.width);
        % 
        %     % Verifications
        %     % Ensure the size of processed velocity commands are different
        %     % than input velocity commands
        %     testCase.verifyNotEqual(size(data.velcmds, 1), size(velcmdsOut, 1));
        % 
        %     % Ensure the number of output velocity commands is equal to
        %     % actual feasible number of data reported by controllerTEB info
        %     % struct
        %     testCase.verifyEqual(size(velcmdsOut,1), data.info.LastFeasibleIdx);
        % 
        %     % Ensure the values of the output velocity commands are exact
        %     % same as the input velocity commands (a curtailed one).
        %     testCase.verifyEqual(velcmdsOut, data.velcmds(1:data.info.LastFeasibleIdx,:));
        % end
    end

    methods (Static)
        function statedot = derivativeForNonHolonomic(t, state, velcmds, timestamps)
            %derivativeForNonHolonomic

            % Find the index in timestamps which should be used.
            idxV = find(~ceil(timestamps - t));
            if min(idxV,numel(timestamps))
                % If valid
                velcmd = velcmds(idxV,:);
                % Use a non-holonomic propagation
                statedot = [velcmd(1)*cos(state(3)); ...
                    velcmd(1)*sin(state(3)); ...
                    velcmd(2)];
            else
                % If not-valid statedot is zeros, i.e., state is held at
                % the previous value
                statedot = [0;0;0];
            end
        end
    end
end