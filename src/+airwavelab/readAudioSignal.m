function signal = readAudioSignal(filePath)
%READAUDIOSIGNAL Read an audio file and convert it to canonical mono form.

    arguments
        filePath (1,1) string
    end

    assert(isfile(filePath), "AirWaveLab:MissingAudio", ...
        "Audio file does not exist: %s", filePath);
    [samples, sampleRate] = audioread(filePath);
    if size(samples, 2) > 1
        samples = mean(samples, 2);
    end
    [~, fileName, extension] = fileparts(filePath);
    signal = airwavelab.createSignal(samples, sampleRate, fileName + extension);
end

