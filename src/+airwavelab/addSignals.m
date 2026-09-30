function output = addSignals(left, right)
%ADDSIGNALS Add two signals after zero-padding to equal length.

    [leftSamples, rightSamples, sampleRate] = alignSignals(left, right);
    output = airwavelab.createSignal(leftSamples + rightSamples, sampleRate, ...
        left.name + " + " + right.name);
end

function [leftSamples, rightSamples, sampleRate] = alignSignals(left, right)
    airwavelab.validateSignal(left);
    airwavelab.validateSignal(right);
    assert(left.sampleRate == right.sampleRate, "AirWaveLab:SampleRateMismatch", ...
        "Signals must have equal sample rates.");
    count = max(numel(left.samples), numel(right.samples));
    leftSamples = [left.samples; zeros(count-numel(left.samples), 1)];
    rightSamples = [right.samples; zeros(count-numel(right.samples), 1)];
    sampleRate = left.sampleRate;
end

