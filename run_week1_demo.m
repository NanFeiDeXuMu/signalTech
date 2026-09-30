function outputs = run_week1_demo()
%RUN_WEEK1_DEMO Run the Lecture 1 AirWaveLab demonstration.

    root = fileparts(mfilename("fullpath"));
    addpath(fullfile(root, "src"));
    rng(1903, "twister");

    outputDirectory = fullfile(root, "results", "week1");
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end

    audioDirectory = fullfile(root, "assets", "audio");
    referencePath = findReferenceWav(audioDirectory);
    if strlength(referencePath) > 0
        original = airwavelab.readAudioSignal(referencePath);
    else
        original = airwavelab.generateSpeechLike(16000, 5, 1903);
    end

    quieter = airwavelab.amplitudeScale(original, 0.5);
    delayed = airwavelab.timeShift(original, round(0.25*original.sampleRate), false);
    echo = airwavelab.addSignals(original, airwavelab.amplitudeScale(delayed, 0.45));
    reversed = airwavelab.timeReverse(original);
    faster = airwavelab.timeScale(original, 1.5);
    slower = airwavelab.timeScale(original, 0.6);
    lfoSamples = 0.7 + 0.3*sin(2*pi*8*original.time);
    lfo = airwavelab.createSignal(lfoSamples, original.sampleRate, "8 Hz LFO");
    tremolo = airwavelab.multiplySignals(original, lfo);

    audioSignals = {original, quieter, echo, reversed, faster, slower, tremolo};
    audioNames = ["original", "quieter", "echo", "reversed", ...
        "faster", "slower", "tremolo"];
    for index = 1:numel(audioSignals)
        airwavelab.writeAudioSignal(audioSignals{index}, ...
            fullfile(outputDirectory, audioNames(index) + ".wav"));
    end

    testSignals = buildTestSignals(original);
    metricsTable = buildMetricsTable(testSignals);
    writetable(metricsTable, fullfile(outputDirectory, "signal_metrics.csv"));

    systemTable = buildSystemTable(original);
    writetable(systemTable, fullfile(outputDirectory, "system_properties.csv"));

    figurePath = fullfile(outputDirectory, "signal_operations.png");
    exportOperationFigure(original, quieter, echo, reversed, faster, tremolo, figurePath);

    baseline = airwavelab.createSignal(original.samples, original.sampleRate, "baseline-output");
    assert(isequal(original.samples, baseline.samples), ...
        "AirWaveLab:BaselineMismatch", "No-op baseline changed the samples.");

    outputs = struct( ...
        "outputDirectory", string(outputDirectory), ...
        "figure", string(figurePath), ...
        "metrics", metricsTable, ...
        "systems", systemTable);
    fprintf("Week 1 demo complete: %s\n", outputDirectory);
end

function filePath = findReferenceWav(audioDirectory)
    preferred = string(fullfile(audioDirectory, "reference.wav"));
    if isfile(preferred)
        filePath = preferred;
        return;
    end
    entries = dir(fullfile(audioDirectory, "*.wav"));
    if isempty(entries)
        filePath = "";
        return;
    end
    [~, order] = sort(lower(string({entries.name})));
    entries = entries(order);
    filePath = string(fullfile(entries(1).folder, entries(1).name));
end

function signals = buildTestSignals(original)
    fs = original.sampleRate;
    duration = min(2, numel(original.samples)/fs);
    count = max(2, round(duration*fs));
    time = reshape(0:count-1, [], 1)/fs;
    sine = airwavelab.createSignal(0.8*sin(2*pi*220*time), fs, "sine");
    pulseSamples = zeros(count, 1);
    pulseSamples(round(0.4*fs):min(count, round(0.7*fs))) = 0.8;
    pulse = airwavelab.createSignal(pulseSamples, fs, "rectangular-pulse");
    decay = airwavelab.createSignal(exp(-3*time).*sin(2*pi*220*time), ...
        fs, "decaying-sine");
    signals = {sine, pulse, decay, original};
end

function value = buildMetricsTable(signals)
    count = numel(signals);
    Name = strings(count, 1);
    SampleCount = zeros(count, 1);
    DurationSeconds = zeros(count, 1);
    Peak = zeros(count, 1);
    RMS = zeros(count, 1);
    Energy = zeros(count, 1);
    AveragePower = zeros(count, 1);
    for index = 1:count
        metrics = airwavelab.measureSignal(signals{index});
        Name(index) = metrics.name;
        SampleCount(index) = metrics.sampleCount;
        DurationSeconds(index) = metrics.durationSeconds;
        Peak(index) = metrics.peak;
        RMS(index) = metrics.rms;
        Energy(index) = metrics.energy;
        AveragePower(index) = metrics.averagePower;
    end
    value = table(Name, SampleCount, DurationSeconds, Peak, RMS, Energy, AveragePower);
end

function value = buildSystemTable(original)
    count = min(4096, numel(original.samples));
    firstInput = original.samples(1:count);
    secondInput = 0.6*sin(2*pi*reshape(0:count-1, [], 1)/73);
    catalog = airwavelab.systemCatalog();
    rowCount = numel(catalog);
    Name = strings(rowCount, 1);
    ExpectedLinear = false(rowCount, 1);
    MeasuredLinear = false(rowCount, 1);
    ExpectedTimeInvariant = false(rowCount, 1);
    MeasuredTimeInvariant = false(rowCount, 1);
    ExpectedCausal = false(rowCount, 1);
    MeasuredCausal = false(rowCount, 1);
    ExpectedStable = false(rowCount, 1);
    OutputPeak = zeros(rowCount, 1);
    for index = 1:rowCount
        report = airwavelab.analyzeSystem(catalog(index).apply, firstInput, secondInput);
        Name(index) = catalog(index).name;
        ExpectedLinear(index) = catalog(index).linear;
        MeasuredLinear(index) = report.appearsLinear;
        ExpectedTimeInvariant(index) = catalog(index).timeInvariant;
        MeasuredTimeInvariant(index) = report.appearsTimeInvariant;
        ExpectedCausal(index) = catalog(index).causal;
        MeasuredCausal(index) = report.appearsCausal;
        ExpectedStable(index) = catalog(index).stable;
        OutputPeak(index) = report.outputPeak;
    end
    value = table(Name, ExpectedLinear, MeasuredLinear, ...
        ExpectedTimeInvariant, MeasuredTimeInvariant, ExpectedCausal, ...
        MeasuredCausal, ExpectedStable, OutputPeak);
end

function exportOperationFigure(original, quieter, echo, reversed, faster, tremolo, filePath)
    signals = {original, quieter, echo, reversed, faster, tremolo};
    titles = ["Original", "Amplitude x0.5", "Echo", ...
        "Time reversal", "Time scale x1.5", "8 Hz tremolo"];
    figureHandle = figure("Visible", "off", "Color", "white", ...
        "Position", [100, 100, 1200, 750]);
    cleanup = onCleanup(@() close(figureHandle));
    layout = tiledlayout(3, 2, "TileSpacing", "compact", "Padding", "compact");
    title(layout, "AirWaveLab Week 1 - Signal Operations");
    for index = 1:numel(signals)
        nexttile;
        previewCount = min(numel(signals{index}.samples), signals{index}.sampleRate);
        plot(signals{index}.time(1:previewCount), signals{index}.samples(1:previewCount));
        grid on;
        title(titles(index));
        xlabel("Time (s)");
        ylabel("Amplitude");
    end
    exportgraphics(figureHandle, filePath, "Resolution", 150);
end
