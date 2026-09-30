function output = timeScale(input, factor)
%TIMESCALE Evaluate y(t)=x(factor*t); factor > 1 is faster.

    airwavelab.validateSignal(input);
    validateattributes(factor, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});
    if factor == 1 || numel(input.samples) == 1
        scaled = input.samples;
    else
        sourceIndex = reshape(0:numel(input.samples)-1, [], 1);
        outputIndex = reshape(0:floor((numel(input.samples)-1)/factor), [], 1);
        scaled = interp1(sourceIndex, input.samples, factor*outputIndex, "linear");
    end
    output = airwavelab.createSignal(scaled, input.sampleRate, ...
        input.name + " | time scale " + string(factor));
end
