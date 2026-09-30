function output = timeReverse(input)
%TIMEREVERSE Reverse sample order.

    airwavelab.validateSignal(input);
    output = airwavelab.createSignal(flipud(input.samples), input.sampleRate, ...
        input.name + " | reversed");
end

