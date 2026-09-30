function report = convertAudioAssets(audioDirectory, overwrite)
%CONVERTAUDIOASSETS Convert supported non-WAV assets to same-name WAV files.

    arguments
        audioDirectory (1,1) string
        overwrite (1,1) logical = false
    end

    assert(isfolder(audioDirectory), "AirWaveLab:MissingAudioDirectory", ...
        "Audio directory does not exist: %s", audioDirectory);

    supported = [".aifc", ".aiff", ".aif", ".au", ".flac", ".ogg", ...
        ".opus", ".mp3", ".m4a", ".mp4"];
    entries = dir(audioDirectory);
    entries = entries(~[entries.isdir]);

    Source = strings(0, 1);
    Target = strings(0, 1);
    Status = strings(0, 1);
    SampleRate = zeros(0, 1);
    Channels = zeros(0, 1);
    DurationSeconds = zeros(0, 1);
    Message = strings(0, 1);

    for index = 1:numel(entries)
        [~, baseName, extension] = fileparts(entries(index).name);
        extension = lower(string(extension));
        if extension == ".wav" || ~any(extension == supported)
            continue;
        end

        sourcePath = string(fullfile(entries(index).folder, entries(index).name));
        targetPath = string(fullfile(entries(index).folder, baseName + ".wav"));
        row = numel(Source) + 1;
        Source(row, 1) = sourcePath;
        Target(row, 1) = targetPath;

        if isfile(targetPath) && ~overwrite
            Status(row, 1) = "skipped";
            Message(row, 1) = "Target exists; pass true to overwrite.";
            info = audioinfo(targetPath);
            SampleRate(row, 1) = info.SampleRate;
            Channels(row, 1) = info.NumChannels;
            DurationSeconds(row, 1) = info.Duration;
            continue;
        end

        try
            [samples, sampleRate] = audioread(sourcePath);
            samples = double(samples);
            clippedCount = nnz(abs(samples) > 1);
            samples = max(-1, min(1, samples));
            audiowrite(targetPath, samples, sampleRate, "BitsPerSample", 24);
            info = audioinfo(targetPath);

            Status(row, 1) = "converted";
            SampleRate(row, 1) = info.SampleRate;
            Channels(row, 1) = info.NumChannels;
            DurationSeconds(row, 1) = info.Duration;
            if clippedCount > 0
                Message(row, 1) = string(clippedCount) + " decoded samples clipped to [-1, 1].";
            else
                Message(row, 1) = "";
            end
        catch exception
            Status(row, 1) = "failed";
            Message(row, 1) = string(exception.message);
        end
    end

    report = table(Source, Target, Status, SampleRate, Channels, ...
        DurationSeconds, Message);
end

