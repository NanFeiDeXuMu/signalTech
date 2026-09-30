function output = amplitudeScale(input, factor)
%AMPLITUDESCALE Scale signal amplitude without implicit clipping.

    airwavelab.validateSignal(input);
    validateattributes(factor, {'numeric'}, {'scalar', 'real', 'finite'});
    output = airwavelab.createSignal(input.samples * factor, ...
        input.sampleRate, input.name + " | amplitude x" + string(factor));
end
