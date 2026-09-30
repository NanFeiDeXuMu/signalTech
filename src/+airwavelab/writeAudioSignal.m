function writeAudioSignal(signal, filePath)
%WRITEAUDIOSIGNAL Write a signal as 24-bit PCM for listening.

    arguments
        signal (1,1) struct
        filePath (1,1) string
    end

    airwavelab.validateSignal(signal);
    parent = fileparts(filePath);
    if strlength(parent) > 0 && ~isfolder(parent)
        mkdir(parent);
    end
    samples = max(-1, min(1, signal.samples));
    audiowrite(filePath, samples, signal.sampleRate, "BitsPerSample", 24);
end

