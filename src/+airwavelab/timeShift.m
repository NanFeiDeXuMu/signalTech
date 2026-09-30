function output = timeShift(input, shiftSamples, preserveLength)
%TIMESHIFT Shift a signal using zero padding.
% Positive shifts delay; negative shifts advance.

    if nargin < 3
        preserveLength = true;
    end
    airwavelab.validateSignal(input);
    validateattributes(shiftSamples, {'numeric'}, {'scalar', 'integer', 'finite'});
    validateattributes(preserveLength, {'logical'}, {'scalar'});

    samples = input.samples;
    count = numel(samples);
    if preserveLength
        shifted = zeros(count, 1);
        if shiftSamples >= 0 && shiftSamples < count
            shifted(shiftSamples+1:end) = samples(1:end-shiftSamples);
        elseif shiftSamples < 0 && -shiftSamples < count
            advance = -shiftSamples;
            shifted(1:end-advance) = samples(advance+1:end);
        end
    elseif shiftSamples >= 0
        shifted = [zeros(shiftSamples, 1); samples];
    else
        advance = min(-shiftSamples, count);
        shifted = samples(advance+1:end);
        if isempty(shifted)
            shifted = 0;
        end
    end

    output = airwavelab.createSignal(shifted, input.sampleRate, ...
        input.name + " | shift " + string(shiftSamples) + " samples");
end
