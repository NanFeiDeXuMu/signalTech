function output = multiplySignals(left, right)
%MULTIPLYSIGNALS Multiply two signals point by point after zero-padding.

    airwavelab.validateSignal(left);
    airwavelab.validateSignal(right);
    assert(left.sampleRate == right.sampleRate, "AirWaveLab:SampleRateMismatch", ...
        "Signals must have equal sample rates.");
    count = max(numel(left.samples), numel(right.samples));
    leftSamples = [left.samples; zeros(count-numel(left.samples), 1)];
    rightSamples = [right.samples; zeros(count-numel(right.samples), 1)];
    output = airwavelab.createSignal(leftSamples .* rightSamples, left.sampleRate, ...
        left.name + " .* " + right.name);
end

