classdef TestSignalOperations < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end
    end

    methods (Test)
        function canonicalSignal(testCase)
            signal = airwavelab.createSignal([1, 2, 3], 10, "test");
            testCase.verifyEqual(signal.samples, [1; 2; 3]);
            testCase.verifyEqual(signal.time, [0; 0.1; 0.2], "AbsTol", 1e-12);
        end

        function amplitudeScaling(testCase)
            signal = airwavelab.createSignal([1; -2], 10, "test");
            output = airwavelab.amplitudeScale(signal, 0.5);
            testCase.verifyEqual(output.samples, [0.5; -1]);
        end

        function shiftingWithPreservedLength(testCase)
            signal = airwavelab.createSignal([1; 2; 3; 4], 10, "test");
            delayed = airwavelab.timeShift(signal, 2, true);
            advanced = airwavelab.timeShift(signal, -2, true);
            testCase.verifyEqual(delayed.samples, [0; 0; 1; 2]);
            testCase.verifyEqual(advanced.samples, [3; 4; 0; 0]);
        end

        function shiftingWithExtendedLength(testCase)
            signal = airwavelab.createSignal([1; 2; 3], 10, "test");
            delayed = airwavelab.timeShift(signal, 2, false);
            testCase.verifyEqual(delayed.samples, [0; 0; 1; 2; 3]);
        end

        function reversingAndTimeScaling(testCase)
            signal = airwavelab.createSignal((1:5)', 10, "test");
            reversed = airwavelab.timeReverse(signal);
            faster = airwavelab.timeScale(signal, 2);
            testCase.verifyEqual(reversed.samples, (5:-1:1)');
            testCase.verifyEqual(faster.samples, [1; 3; 5]);
        end

        function additionAndMultiplication(testCase)
            left = airwavelab.createSignal([1; 2], 10, "left");
            right = airwavelab.createSignal([3; 4; 5], 10, "right");
            added = airwavelab.addSignals(left, right);
            multiplied = airwavelab.multiplySignals(left, right);
            testCase.verifyEqual(added.samples, [4; 6; 5]);
            testCase.verifyEqual(multiplied.samples, [3; 8; 0]);
        end

        function energyAndPowerMetrics(testCase)
            signal = airwavelab.createSignal([1; -1; 1; -1], 4, "test");
            metrics = airwavelab.measureSignal(signal);
            testCase.verifyEqual(metrics.energy, 4);
            testCase.verifyEqual(metrics.averagePower, 1);
            testCase.verifyEqual(metrics.rms, 1);
        end

        function noOpBaselineIsExact(testCase)
            input = airwavelab.generateSpeechLike(8000, 0.1, 1903);
            output = airwavelab.createSignal(input.samples, input.sampleRate, "output");
            testCase.verifyEqual(output.samples, input.samples);
        end

        function audioAssetConversion(testCase)
            directory = string(tempname);
            mkdir(directory);
            cleanup = onCleanup(@() rmdir(directory, "s"));
            sampleRate = 8000;
            samples = 0.5*sin(2*pi*220*(0:799)'/sampleRate);
            sourcePath = fullfile(directory, "sample.flac");
            audiowrite(sourcePath, samples, sampleRate);

            report = airwavelab.convertAudioAssets(directory, false);
            targetPath = fullfile(directory, "sample.wav");
            testCase.verifyEqual(report.Status, "converted");
            testCase.verifyTrue(isfile(targetPath));
            info = audioinfo(targetPath);
            testCase.verifyEqual(info.SampleRate, sampleRate);
            testCase.verifyEqual(info.NumChannels, 1);

            secondReport = airwavelab.convertAudioAssets(directory, false);
            testCase.verifyEqual(secondReport.Status, "skipped");
        end
    end
end
