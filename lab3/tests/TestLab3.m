classdef TestLab3 < matlab.unittest.TestCase
    properties
        Synthesis
        OutputDir
    end
    methods (TestClassSetup)
        function prepare(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                {fullfile(root,'common'),fullfile(root,'task1'),fullfile(root,'task2')}));
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.OutputDir = folder.Folder;
            cfg = lab3_config(folder.Folder);
            testCase.Synthesis = play_melody_timbre(cfg);
        end
    end
    methods (Test)
        function coherentHarmonicAmplitudes(testCase)
            [y,t,f0] = generate_harmonic_tone(6,8000,0.35,0.1);
            [f,a] = single_sided_spectrum(y,8000);
            weights = [1,.45,.25,.12,.06]';
            bins = round((1:5)'*440/10)+1;
            testCase.verifyEqual(f0,440);
            testCase.verifyEqual(f(bins),(1:5)'*440);
            testCase.verifyEqual(a(bins),0.35*weights,'AbsTol',1e-12);
            testCase.verifyEqual(numel(y),800);
            testCase.verifyEqual(t(end),799/8000);
            testCase.verifySize(y,[800,1]);
            other = a; other(bins)=0;
            testCase.verifyLessThan(max(other),1e-12);
        end
        function aliasingRejected(testCase)
            testCase.verifyError(@() generate_harmonic_tone(7,4000,.35,.4),'Lab3:Aliasing');
        end
        function envelopeShapeAndSmallInputs(testCase)
            for N = [1,2,3,19,20,3200,6400]
                e = generate_piano_envelope(N);
                testCase.verifySize(e,[N,1]);
                testCase.verifyEqual(e(1),0);
                testCase.verifyEqual(e(end),0);
                testCase.verifyGreaterThanOrEqual(e,0);
                testCase.verifyLessThanOrEqual(e,1);
                if N >= 3
                    [peak,k] = max(e);
                    testCase.verifyEqual(peak,1);
                    testCase.verifyGreaterThanOrEqual(diff(e(1:k)),0);
                    testCase.verifyLessThanOrEqual(diff(e(k:end)),0);
                end
            end
            e = generate_piano_envelope(3200);
            testCase.verifyEqual(e(160:161),[1;1]);
        end
        function scoreAndEnvelopeAppliedPerNote(testCase)
            s = testCase.Synthesis;
            testCase.verifySize(s.harmonic,[51200,1]);
            testCase.verifyEqual(s.notes.StartSample(1),1);
            testCase.verifyEqual(s.notes.EndSample(end),51200);
            testCase.verifyEqual(sum(s.notes.Beats),16);
            testCase.verifyEqual(s.notes.StartSample(2:end),s.notes.EndSample(1:end-1)+1);
            for j = 1:height(s.notes)
                idx = s.notes.StartSample(j):s.notes.EndSample(j);
                testCase.verifyEqual(s.timbre(idx),s.harmonic(idx).*generate_piano_envelope(numel(idx)));
                testCase.verifyEqual(s.timbre(idx([1,end])),[0;0]);
            end
            testCase.verifyGreaterThan(s.metrics.MaxBoundaryJump(1),0.1);
            testCase.verifyEqual(s.metrics.MaxBoundaryJump(2),0);
            testCase.verifyLessThan(max(abs([s.harmonic;s.timbre])),1);
        end
        function wavQuantizationAndExactPcmRoundTrip(testCase)
            names = {'task2_harmonic_melody.wav','task2_timbre_melody.wav'};
            original = {testCase.Synthesis.harmonic,testCase.Synthesis.timbre};
            for k = 1:2
                path = fullfile(testCase.OutputDir,names{k});
                [decoded,fs] = audioread(path);
                testCase.verifyEqual(fs,8000);
                testCase.verifyLessThanOrEqual(max(abs(decoded-original{k})),2^-23);
                integers = audioread(path,'native');
                reencoded = fullfile(testCase.OutputDir,sprintf('roundtrip%d.wav',k));
                audiowrite(reencoded,decoded,fs,'BitsPerSample',24);
                testCase.verifyEqual(audioread(reencoded,'native'),integers);
            end
        end
        function spectrumEvenDcAndNyquist(testCase)
            n = (0:799)';
            x = .2+.3*cos(2*pi*100*n/800)+.1*(-1).^n;
            [f,a] = single_sided_spectrum(x,8000);
            testCase.verifyEqual(a([1,101,end]),[.2;.3;.1],'AbsTol',1e-12);
            testCase.verifyEqual(f([1,101,end]),[0;1000;4000]);
        end
        function spectrumOddLastBin(testCase)
            N=801; n=(0:N-1)';
            [f,a] = single_sided_spectrum(.4*cos(2*pi*400*n/N),8000);
            testCase.verifyEqual(a(end),.4,'AbsTol',1e-12);
            testCase.verifyEqual(f(end),400*8000/N);
        end
        function stftAgreesWithDirectDft(testCase)
            x = sin((0:22)'*.71)+.2*cos((0:22)'*1.12);
            L=8; overlap=3; nfft=11; fs=100;
            [S,f,t,~,info] = stft_base(x,fs,L,overlap,nfft);
            w=.54-.46*cos(2*pi*(0:L-1)'/(L-1));
            % Explicit matrix DFT is an independent reference to FFT.
            D=exp(-2i*pi*(0:floor(nfft/2))'*(0:L-1)/nfft);
            for j=1:4
                idx=(j-1)*5+(1:L);
                testCase.verifyEqual(S(:,j),D*(x(idx).*w),'AbsTol',1e-12);
            end
            testCase.verifyEqual(t,[3.5,8.5,13.5,18.5]/fs,'AbsTol',1e-12);
            testCase.verifyEqual(f,(0:5)'*fs/nfft);
            testCase.verifyEqual(info.discardedTailSamples,0);
        end
        function stftToneAmplitudeAndFrameTimes(testCase)
            fs=8000; x=.6*cos(2*pi*1000*(0:2047)'/fs);
            [~,f,t,a,info]=stft_base(x,fs,256,128,512);
            bin=find(f==1000);
            testCase.verifyEqual(a(bin,:),repmat(.6,1,15),'AbsTol',4e-5);
            testCase.verifyEqual(t(1),127.5/fs);
            testCase.verifyEqual(diff(t),repmat(128/fs,1,14),'AbsTol',1e-14);
            testCase.verifyEqual(info.frameCount,15);
        end
        function stftDcNyquistAndTail(testCase)
            x=.2+.1*(-1).^(0:999)';
            [~,~,~,a,info]=stft_base(x,8000,128,0,128);
            testCase.verifyEqual(a(1,:),repmat(.2,1,7),'AbsTol',1e-12);
            testCase.verifyEqual(a(end,:),repmat(.1,1,7),'AbsTol',1e-12);
            testCase.verifyEqual(info.discardedTailSamples,104);
        end
        function zeroPaddingRetainsOriginalDftSamples(testCase)
            x=cos(2*pi*.113*(0:511)');
            [S1,~,t1]=stft_base(x,8000,256,128,256);
            [S2,~,t2]=stft_base(x,8000,256,128,1024);
            testCase.verifyEqual(S2(1:4:end,:),S1,'AbsTol',1e-12);
            testCase.verifyEqual(t1,t2);
        end
        function toolboxReferenceWhenAvailable(testCase)
            if isempty(which('spectrogram'))
                % The explicit DFT test is always run; no toolbox is required.
                testCase.verifyEmpty(which('spectrogram'));
                return
            end
            x=sin((0:2047)'*.19); L=256;
            w=.54-.46*cos(2*pi*(0:L-1)'/(L-1));
            [S,f,t]=stft_base(x,8000,L,128,512);
            [reference,rf,rt]=spectrogram(x,w,128,512,8000);
            testCase.verifyEqual(S,reference,'AbsTol',1e-11);
            testCase.verifyEqual(f,rf,'AbsTol',1e-11);
            % MATLAB locates the center at L/2; our sample-center mean is (L-1)/2.
            testCase.verifyEqual(rt(:)-t(:),repmat(.5/8000,numel(t),1),'AbsTol',1e-12);
        end
    end
end
