classdef TestLecture2Extension < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end
    end

    methods (Test)
        function harmonicCoefficientsAndReconstruction(testCase)
            sampleRate = 8000;
            frequency = 200;
            amplitudes = [0.60; 0.25; 0.10];
            phases = [0.20; -0.30; 0.70];
            signal = airwavelab.synthesizeHarmonicTone( ...
                frequency, amplitudes, phases, sampleRate, 0.1);
            analysis = airwavelab.analyzeHarmonics(signal, frequency, 3);

            testCase.verifyEqual(analysis.amplitude, amplitudes, "AbsTol", 1e-12);
            testCase.verifyEqual(analysis.phaseRadians, phases, "AbsTol", 1e-12);
            testCase.verifyEqual(analysis.reconstruction.samples, ...
                signal.samples, "AbsTol", 2e-12);
            testCase.verifyGreaterThan(analysis.reconstructionSnrDb, 230);
        end

        function fundamentalFrequencyFromPureAndRichTones(testCase)
            sampleRate = 8000;
            pure = airwavelab.synthesizeHarmonicTone(220, ...
                [0.7; 0; 0], zeros(3, 1), sampleRate, 0.08);
            rich = airwavelab.synthesizeHarmonicTone(220, ...
                [0.7; 0.25; 0.1], zeros(3, 1), sampleRate, 0.08);
            purePitch = airwavelab.estimateFundamentalFrequency(pure, [100, 350]);
            richPitch = airwavelab.estimateFundamentalFrequency(rich, [100, 350]);

            testCase.verifyEqual(purePitch.frequencyHz, 220, "AbsTol", 1.0);
            testCase.verifyEqual(richPitch.frequencyHz, 220, "AbsTol", 1.0);
        end

        function adsrShapeAndMultiplication(testCase)
            sampleRate = 1000;
            signal = airwavelab.createSignal(ones(1000, 1), sampleRate, "ones");
            config = struct("attackSeconds", 0.1, "decaySeconds", 0.1, ...
                "sustainLevel", 0.4, "releaseSeconds", 0.1);
            [output, envelope] = airwavelab.applyAdsr(signal, config);

            testCase.verifyEqual(envelope(1), 0, "AbsTol", 1e-12);
            testCase.verifyEqual(envelope(100), 1, "AbsTol", 1e-12);
            testCase.verifyEqual(envelope(200), 0.4, "AbsTol", 1e-12);
            testCase.verifyEqual(envelope(500), 0.4, "AbsTol", 1e-12);
            testCase.verifyEqual(envelope(end), 0, "AbsTol", 1e-12);
            testCase.verifyEqual(output.samples, signal.samples.*envelope);
        end

        function pcmExactQuantizedRoundTrip(testCase)
            samples = [-1; -0.5; -0.125; 0; 0.25; 0.75];
            signal = airwavelab.createSignal(samples, 8000, "grid-aligned");
            packet = airwavelab.pcmEncode(signal, 4);
            decoded = airwavelab.pcmDecode(packet);
            secondPacket = airwavelab.pcmEncode(decoded, 4);

            testCase.verifyEqual(decoded.samples, samples);
            testCase.verifyEqual(secondPacket.bitstream, packet.bitstream);
            testCase.verifyEqual(numel(packet.bitstream), 4*numel(samples));
        end

        function pcmQualityImprovesWithBitDepth(testCase)
            time = (0:7999)'/8000;
            signal = airwavelab.createSignal(0.73*sin(2*pi*317*time), 8000, "tone");
            low = airwavelab.pcmDecode(airwavelab.pcmEncode(signal, 4));
            high = airwavelab.pcmDecode(airwavelab.pcmEncode(signal, 12));
            lowMetrics = airwavelab.compareSignals(signal, low);
            highMetrics = airwavelab.compareSignals(signal, high);

            testCase.verifyLessThan(highMetrics.mse, lowMetrics.mse);
            testCase.verifyGreaterThan(highMetrics.reconstructionSnrDb, ...
                lowMetrics.reconstructionSnrDb + 35);
        end

        function identityResamplingIsExact(testCase)
            signal = airwavelab.generateSpeechLike(8000, 0.1, 1903);
            output = airwavelab.resampleSignal(signal, signal.sampleRate);
            testCase.verifyEqual(output.samples, signal.samples);
            testCase.verifyEqual(output.sampleRate, signal.sampleRate);
        end

        function configurableSampleRatePreservesLowTone(testCase)
            source = airwavelab.synthesizeHarmonicTone(500, 0.7, 0, ...
                48000, 0.1);
            output = airwavelab.resampleSignal(source, 8000);
            pitch = airwavelab.estimateFundamentalFrequency(output, [300, 700]);

            testCase.verifyEqual(output.sampleRate, 8000);
            testCase.verifyEqual(numel(output.samples), 800);
            testCase.verifyEqual(pitch.frequencyHz, 500, "AbsTol", 2);
        end
    end
end
