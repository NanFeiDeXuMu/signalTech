classdef TestSystemProperties < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end
    end

    methods (Test)
        function empiricalChecksMatchCatalog(testCase)
            sampleCount = 256;
            first = sin(2*pi*(0:sampleCount-1)'/31);
            second = cos(2*pi*(0:sampleCount-1)'/47);
            catalog = airwavelab.systemCatalog();
            for index = 1:numel(catalog)
                report = airwavelab.analyzeSystem(catalog(index).apply, first, second);
                testCase.verifyEqual(report.appearsLinear, catalog(index).linear, ...
                    "System: " + catalog(index).name);
                testCase.verifyEqual(report.appearsTimeInvariant, ...
                    catalog(index).timeInvariant, "System: " + catalog(index).name);
                testCase.verifyEqual(report.appearsCausal, catalog(index).causal, ...
                    "System: " + catalog(index).name);
            end
        end

        function rowInputsAreNormalized(testCase)
            first = sin(2*pi*(0:127)/31);
            second = cos(2*pi*(0:127)/47);
            report = airwavelab.analyzeSystem(@(x) 2*x, first, second);
            testCase.verifyTrue(report.appearsLinear);
            testCase.verifyTrue(report.appearsTimeInvariant);
            testCase.verifyTrue(report.appearsCausal);
        end
    end
end
