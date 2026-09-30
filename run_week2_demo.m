function outputs = run_week2_demo()
%RUN_WEEK2_DEMO Connect Lecture 2 audio concepts to the PCM PRD stage.

    root = fileparts(mfilename("fullpath"));
    addpath(fullfile(root, "src"));
    rng(1903, "twister");

    outputDirectory = fullfile(root, "results", "week2");
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end

    original = loadDemoAudio(root);
    maximumSamples = min(numel(original.samples), round(3*original.sampleRate));
    original = airwavelab.createSignal(original.samples(1:maximumSamples), ...
        original.sampleRate, original.name + " | 3 s excerpt");
    sampled = airwavelab.resampleSignal(original, 16000);
    identity = airwavelab.resampleSignal(sampled, sampled.sampleRate);
    assert(isequal(sampled.samples, identity.samples), ...
        "AirWaveLab:IdentityResamplingFailed", ...
        "Identity-rate resampling changed the audio samples.");

    [frame, frameStart] = selectHighEnergyFrame(sampled, 0.080);
    pitchReference = airwavelab.estimateFundamentalFrequency(frame, [70, 400]);
    harmonicCount = min(10, floor((sampled.sampleRate/2-1) / ...
        pitchReference.frequencyHz));
    harmonicAnalysis = airwavelab.analyzeHarmonics( ...
        frame, pitchReference.frequencyHz, harmonicCount);

    bitDepths = [4; 8; 12; 16];
    pcmSignals = cell(numel(bitDepths), 1);
    BitRateKbps = zeros(size(bitDepths));
    MSE = zeros(size(bitDepths));
    ReconstructionSNRdB = zeros(size(bitDepths));
    EstimatedFundamentalHz = zeros(size(bitDepths));
    PitchDeviationHz = zeros(size(bitDepths));
    for index = 1:numel(bitDepths)
        packet = airwavelab.pcmEncode(sampled, bitDepths(index));
        pcmSignals{index} = airwavelab.pcmDecode(packet);
        roundTripPacket = airwavelab.pcmEncode(pcmSignals{index}, bitDepths(index));
        assert(isequal(packet.bitstream, roundTripPacket.bitstream), ...
            "AirWaveLab:PCMBitRoundTripFailed", ...
            "PCM decode and re-encode changed the quantized bitstream.");

        metrics = airwavelab.compareSignals(sampled, pcmSignals{index});
        quantizedFrame = airwavelab.createSignal( ...
            pcmSignals{index}.samples(frameStart:frameStart+numel(frame.samples)-1), ...
            sampled.sampleRate, "PCM frame");
        pitch = airwavelab.estimateFundamentalFrequency(quantizedFrame, [70, 400]);

        BitRateKbps(index) = sampled.sampleRate*bitDepths(index)/1000;
        MSE(index) = metrics.mse;
        ReconstructionSNRdB(index) = metrics.reconstructionSnrDb;
        EstimatedFundamentalHz(index) = pitch.frequencyHz;
        PitchDeviationHz(index) = pitch.frequencyHz-pitchReference.frequencyHz;
        airwavelab.writeAudioSignal(pcmSignals{index}, fullfile( ...
            outputDirectory, "speech_pcm_" + string(bitDepths(index)) + "bit.wav"));
    end
    BitDepth = bitDepths;
    pcmMetrics = table(BitDepth, BitRateKbps, MSE, ReconstructionSNRdB, ...
        EstimatedFundamentalHz, PitchDeviationHz);
    writetable(pcmMetrics, fullfile(outputDirectory, "pcm_tradeoff_metrics.csv"));

    Harmonic = harmonicAnalysis.harmonicNumber;
    FrequencyHz = harmonicAnalysis.frequencyHz;
    CosineCoefficient = harmonicAnalysis.cosineCoefficient;
    SineCoefficient = harmonicAnalysis.sineCoefficient;
    Amplitude = harmonicAnalysis.amplitude;
    RelativeAmplitudeDb = 20*log10(max(Amplitude, eps) / max(max(Amplitude), eps));
    harmonicMetrics = table(Harmonic, FrequencyHz, CosineCoefficient, ...
        SineCoefficient, Amplitude, RelativeAmplitudeDb);
    writetable(harmonicMetrics, fullfile(outputDirectory, "speech_harmonics.csv"));

    [pureTone, richTone, envelope] = createTimbreExamples();
    airwavelab.writeAudioSignal(pureTone, ...
        fullfile(outputDirectory, "pure_tone_adsr.wav"));
    airwavelab.writeAudioSignal(richTone, ...
        fullfile(outputDirectory, "rich_tone_adsr.wav"));
    airwavelab.writeAudioSignal(sampled, ...
        fullfile(outputDirectory, "speech_16khz_reference.wav"));

    conceptsFigure = fullfile(outputDirectory, "lecture2_concepts.png");
    exportConceptsFigure(pureTone, richTone, envelope, conceptsFigure);
    tradeoffFigure = fullfile(outputDirectory, "pcm_harmonic_tradeoff.png");
    fourBitFrame = airwavelab.createSignal( ...
        pcmSignals{1}.samples(frameStart:frameStart+numel(frame.samples)-1), ...
        sampled.sampleRate, "4-bit PCM voiced frame");
    exportTradeoffFigure(frame, fourBitFrame, harmonicAnalysis, ...
        pcmMetrics, pitchReference, tradeoffFigure);

    summary = table( ...
        pitchReference.frequencyHz, pitchReference.periodSeconds*1000, ...
        pitchReference.confidence, harmonicAnalysis.reconstructionSnrDb, ...
        'VariableNames', {'FundamentalFrequencyHz', 'PeriodMilliseconds', ...
        'PitchConfidence', 'TenHarmonicReconstructionSNRdB'});
    writetable(summary, fullfile(outputDirectory, "lecture2_summary.csv"));

    outputs = struct( ...
        "outputDirectory", string(outputDirectory), ...
        "conceptsFigure", string(conceptsFigure), ...
        "tradeoffFigure", string(tradeoffFigure), ...
        "pcmMetrics", pcmMetrics, ...
        "harmonicMetrics", harmonicMetrics, ...
        "summary", summary);
    fprintf("Week 2 demo complete: %s\n", outputDirectory);
end

function signal = loadDemoAudio(root)
    audioDirectory = fullfile(root, "assets", "audio");
    preferred = string(fullfile(audioDirectory, "reference.wav"));
    if isfile(preferred)
        signal = airwavelab.readAudioSignal(preferred);
        return;
    end
    entries = dir(fullfile(audioDirectory, "*.wav"));
    if isempty(entries)
        signal = airwavelab.generateSpeechLike(16000, 3, 1903);
        return;
    end
    [~, order] = sort(lower(string({entries.name})));
    entry = entries(order(1));
    signal = airwavelab.readAudioSignal(string(fullfile(entry.folder, entry.name)));
end

function [frame, startSample] = selectHighEnergyFrame(signal, durationSeconds)
    frameCount = min(numel(signal.samples), round(durationSeconds*signal.sampleRate));
    assert(frameCount >= ceil(2*signal.sampleRate/70), ...
        "AirWaveLab:AudioTooShort", ...
        "Demo audio is too short for an 80 ms pitch-analysis frame.");
    hop = max(1, floor(frameCount/2));
    starts = 1:hop:max(1, numel(signal.samples)-frameCount+1);
    finalStart = numel(signal.samples)-frameCount+1;
    if starts(end) ~= finalStart
        starts(end+1) = finalStart;
    end
    energies = zeros(size(starts));
    for index = 1:numel(starts)
        samples = signal.samples(starts(index):starts(index)+frameCount-1);
        energies(index) = mean(samples.^2);
    end
    [~, best] = max(energies);
    startSample = starts(best);
    frame = airwavelab.createSignal( ...
        signal.samples(startSample:startSample+frameCount-1), ...
        signal.sampleRate, signal.name + " | voiced 80 ms frame");
end

function [pureTone, richTone, envelope] = createTimbreExamples()
    sampleRate = 16000;
    durationSeconds = 1.5;
    frequency = 220;
    phases = zeros(5, 1);
    pure = airwavelab.synthesizeHarmonicTone( ...
        frequency, [0.55; 0; 0; 0; 0], phases, sampleRate, durationSeconds);
    rich = airwavelab.synthesizeHarmonicTone( ...
        frequency, [0.55; 0.23; 0.12; 0.07; 0.03], ...
        phases, sampleRate, durationSeconds);
    pureRms = airwavelab.measureSignal(pure).rms;
    richRms = airwavelab.measureSignal(rich).rms;
    rich = airwavelab.amplitudeScale(rich, pureRms/richRms);
    config = struct("attackSeconds", 0.08, "decaySeconds", 0.18, ...
        "sustainLevel", 0.55, "releaseSeconds", 0.25);
    [pureTone, envelope] = airwavelab.applyAdsr(pure, config);
    richTone = airwavelab.applyAdsr(rich, config);
end

function exportConceptsFigure(pureTone, richTone, envelope, filePath)
    figureHandle = figure("Visible", "off", "Color", "white", ...
        "Position", [100, 100, 1200, 760]);
    cleanup = onCleanup(@() close(figureHandle));
    layout = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");
    title(layout, "Lecture 2 in AirWaveLab: Pitch, Timbre, and Envelope");

    previewCount = round(3*pureTone.sampleRate/220);
    nexttile;
    plot(1000*pureTone.time(1:previewCount), pureTone.samples(1:previewCount), ...
        "LineWidth", 1.2);
    hold on;
    plot(1000*richTone.time(1:previewCount), richTone.samples(1:previewCount), ...
        "LineWidth", 1.0);
    grid on;
    xlabel("Time (ms)");
    ylabel("Amplitude");
    title("Same 220 Hz pitch, different waveform");
    legend("Pure", "Rich", "Location", "best");

    nexttile;
    stem(1:5, [1, 0, 0, 0, 0], "filled", "LineWidth", 1.2);
    hold on;
    stem(1:5, [1, 0.23/0.55, 0.12/0.55, 0.07/0.55, 0.03/0.55], ...
        "LineWidth", 1.2);
    grid on;
    xlabel("Harmonic number");
    ylabel("Amplitude relative to fundamental");
    title("Harmonic distribution controls timbre");
    legend("Pure", "Rich", "Location", "northeast");

    nexttile;
    plot(pureTone.time, envelope, "LineWidth", 1.4);
    grid on;
    ylim([-0.05, 1.05]);
    xlabel("Time (s)");
    ylabel("Envelope e(t)");
    title("ADSR envelope: y(t) = x(t)e(t)");

    nexttile;
    analysisPure = airwavelab.analyzeHarmonics(pureTone, 220, 5);
    analysisRich = airwavelab.analyzeHarmonics(richTone, 220, 5);
    bar(1:5, [analysisPure.amplitude, analysisRich.amplitude]);
    grid on;
    xlabel("Harmonic number");
    ylabel("Fourier amplitude");
    title("Measured Fourier coefficients");
    legend("Pure", "Rich", "Location", "northeast");
    exportgraphics(figureHandle, filePath, "Resolution", 150);
end

function exportTradeoffFigure(frame, fourBitFrame, harmonicAnalysis, ...
        metrics, pitchReference, filePath)
    figureHandle = figure("Visible", "off", "Color", "white", ...
        "Position", [100, 100, 1200, 760]);
    cleanup = onCleanup(@() close(figureHandle));
    layout = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");
    title(layout, "AirWaveLab PCM Trade-off with Lecture 2 Measurements");

    previewCount = min(round(0.020*frame.sampleRate), numel(frame.samples));
    nexttile;
    plot(1000*frame.time(1:previewCount), frame.samples(1:previewCount), ...
        "LineWidth", 1.1);
    hold on;
    stairs(1000*fourBitFrame.time(1:previewCount), ...
        fourBitFrame.samples(1:previewCount));
    grid on;
    xlabel("Time (ms)");
    ylabel("Amplitude");
    title("PCM quantization in time");
    legend("Voiced frame", "4-bit PCM", "Location", "best");

    nexttile;
    plot(metrics.BitRateKbps, metrics.ReconstructionSNRdB, "-o", ...
        "LineWidth", 1.4, "MarkerFaceColor", [0.1, 0.45, 0.8]);
    grid on;
    xlabel("Uncompressed PCM bitrate (kb/s)");
    ylabel("Reconstruction SNR (dB)");
    title("Bitrate-quality trade-off");

    nexttile;
    plot(metrics.BitDepth, metrics.EstimatedFundamentalHz, "-o", ...
        "LineWidth", 1.4);
    hold on;
    yline(pitchReference.frequencyHz, "--", "Reference");
    grid on;
    xlabel("PCM bit depth");
    ylabel("Estimated fundamental (Hz)");
    title("Pitch robustness under quantization");

    nexttile;
    previewCount = min(round(0.030*frame.sampleRate), numel(frame.samples));
    plot(1000*frame.time(1:previewCount), frame.samples(1:previewCount), ...
        "LineWidth", 1.1);
    hold on;
    plot(1000*harmonicAnalysis.reconstruction.time(1:previewCount), ...
        harmonicAnalysis.reconstruction.samples(1:previewCount), ...
        "LineWidth", 1.1);
    grid on;
    xlabel("Frame time (ms)");
    ylabel("Amplitude");
    title(string(numel(harmonicAnalysis.harmonicNumber)) + ...
        "-harmonic Fourier reconstruction");
    legend("Voiced frame", "Reconstruction", "Location", "best");
    exportgraphics(figureHandle, filePath, "Resolution", 150);
end
