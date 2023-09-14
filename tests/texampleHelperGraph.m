classdef texampleHelperGraph < matlab.unittest.TestCase
    %texampleHelperGraph - Unit tests for example helper for graph
    
    % Copyright 2023 The MathWorks, Inc.
    
    methods (Test)
        function path2GraphData(testCase)
            % path2GraphData
            [expectedStates, ~, pathBranches, pathFull] = texampleHelperGraph.createTree();

            % Case1: Check if the same set of nodes/states are detected or not
            pathOutBranches = exampleHelperPath2GraphData(pathBranches);
            pathOutFull = exampleHelperPath2GraphData(pathFull);

            % Verification
            % Ensure the results are part of all expectedStates
            sortuniq = @(x)sortrows(unique(x(:,1:2),'rows'));
            testCase.verifyTrue(all(ismember(sortuniq(pathOutBranches), sortuniq(expectedStates),'rows')));
            testCase.verifyTrue(all(ismember(sortuniq(pathOutFull), sortuniq(expectedStates),'rows')));
            
            % Ensure the output is inline with expectations
            testCase.verifyEqual(pathOutBranches(:,1:2), uniqueEdges(pathBranches));
            testCase.verifyEqual(pathOutFull(:,1:2), uniqueEdges(pathFull));
            

            % Case2: Use discretization
            numDiscretize = 3;
            pathOutBranchesDiscretized = exampleHelperPath2GraphData(pathBranches, numDiscretize);
            pathOutFullDiscretized = exampleHelperPath2GraphData(pathFull, numDiscretize);

            % Verification
            % Ensure pathOutBranches is unModified (as numDiscretized ==
            % size of pathBranches)
            testCase.verifyEqual(pathOutBranchesDiscretized, pathOutBranches);
            % Ensure the size of pathFull out is different as it is
            % expected to be discretized
            testCase.verifyGreaterThan(size(pathOutFullDiscretized,1), size(pathOutFull,1));

            function out = uniqueEdges(apathStructArray)
                %uniqueEdges
                extractEdges = arrayfun(@(x)[x.Path([1 end],1:2)], apathStructArray, 'UniformOutput', false);
                out = unique(cat(1,extractEdges{:}),'rows');
            end
        end
    end
    
    methods (Static)
        function [states, edges, pathStructOnlyBranches, pathStructFullPaths] = createTree()
            % createTree - Create a path on grid, and return sequence of
            % edges
           
            % [nodeID1 nodeID2] % EdgeId
            edges = [1 2; % 1
                2 3; % 2
                2 4; % 3 
                4 5; % 4
                4 7; % 5
                7 6]; % 6

            % states: [ x y ] % nodeID
            states = [0 0; %1
                1 0; %2
                2 0; %3
                1 1; %4 
                1 2; %5
                2 2; %6
                2 1;]; %7

            % pathStructOnlyBranches - input is edgeIds representing a
            % branch
            branch1 = createBranch([1]);
            branch2 = createBranch([2]);
            branch3 = createBranch([3]);
            branch4 = createBranch([5 6]);

            pathStructOnlyBranches(1) = struct('Path', branch1);
            pathStructOnlyBranches(2) = struct('Path', branch2);
            pathStructOnlyBranches(3) = struct('Path', branch3);
            pathStructOnlyBranches(4) = struct('Path', branch4);


            % pathStructFullPaths  - input is edgeIds representing a
            % path
            branch1 = createBranch([1 2]);
            branch2 = createBranch([1 3 4]);
            branch3 = createBranch([1 3 5 6]);

            pathStructFullPaths(1) = struct('Path', branch1);
            pathStructFullPaths(2) = struct('Path', branch2);
            pathStructFullPaths(3) = struct('Path', branch3);

            function path = createBranch(listOfEdges)
                path = states(edges(listOfEdges(1),1),:);
                for iedge = listOfEdges
                    path = [path;states(edges(iedge,2),:)];
                end
            end
        end
    end
end