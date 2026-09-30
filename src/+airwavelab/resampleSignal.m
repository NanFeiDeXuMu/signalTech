function output = resampleSignal(input, targetSampleRate)
%RESAMPLESIGNAL Deterministically change rate with FIR anti-alias filtering.
% This educational base-MATLAB implementation uses a windowed-sinc low-pass
% filter before downsampling and linear interpolation at the target times.

    airwavelab.validateSignal(input);
    validateattributes(targetSampleRate, {'numeric'}, ...
        {'scalar', 'real', 'positive', 'finite'});
    targetSampleRate = double(targetSampleRate);
    if targetSampleRate == input.sampleRate || numel(input.samples) == 1
        output = airwavelab.createSignal(input.samples, targetSampleRate, ...
            input.name + " | " + string(targetSampleRate) + " Hz");
        return;
    end

    samples = input.samples;
    if targetSampleRate < input.sampleRate
        cutoffHz = 0.45*targetSampleRate;
        halfLength = max(16, ceil(8*input.sampleRate/targetSampleRate));
        tapIndex = reshape(-halfLength:halfLength, [], 1);
        normalizedArgument = 2*cutoffHz/input.sampleRate * tapIndex;
        sincValues = ones(size(normalizedArgument));
        nonzero = normalizedArgument ~= 0;
        sincValues(nonzero) = sin(pi*normalizedArgument(nonzero)) ./ ...
            (pi*normalizedArgument(nonzero));
        taps = (2*cutoffHz/input.sampleRate) * sincValues;
        window = 0.54 - 0.46*cos(2*pi*(0:numel(taps)-1)'/(numel(taps)-1));
        taps = taps .* window;
        taps = taps / sum(taps);
        samples = conv(samples, taps, "same");
    end

    outputCount = max(1, floor((numel(samples)-1) * ...
        targetSampleRate/input.sampleRate) + 1);
    sourceTime = reshape(0:numel(samples)-1, [], 1) / input.sampleRate;
    targetTime = reshape(0:outputCount-1, [], 1) / targetSampleRate;
    resampled = interp1(sourceTime, samples, targetTime, "linear");
    output = airwavelab.createSignal(resampled, targetSampleRate, ...
        input.name + " | " + string(targetSampleRate) + " Hz");
end
