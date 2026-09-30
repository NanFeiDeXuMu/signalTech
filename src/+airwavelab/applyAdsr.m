function [output, envelope] = applyAdsr(input, config)
%APPLYADSR Multiply a signal by an ADSR amplitude envelope.

    airwavelab.validateSignal(input);
    envelope = airwavelab.adsrEnvelope( ...
        numel(input.samples), input.sampleRate, config);
    output = airwavelab.createSignal(input.samples .* envelope, ...
        input.sampleRate, input.name + " | ADSR");
end
