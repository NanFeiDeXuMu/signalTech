function [y, t] = generate_tone(degree, sample_rate, amplitude, duration)
% GENERATE_TONE Generate a pure sinusoid tone for a given scale degree.
%   [Y, T] = GENERATE_TONE(DEGREE, SAMPLE_RATE, AMPLITUDE, DURATION)
%   creates a pure sinusoidal waveform at the frequency corresponding to
%   the input scale degree (1=Do, 2=Re, 3=Mi, 4=Fa, 5=So, 6=La, 7=Ti)
%   using the standard A440 equal-tempered tuning.
%
%   Inputs:
%       DEGREE       - Scale degree (integer between 1 and 7)
%       SAMPLE_RATE  - Sampling rate in samples per second (Hz)
%       AMPLITUDE    - Peak amplitude of the sinusoid (scalar)
%       DURATION     - Duration of the tone in seconds (scalar)
%
%   Outputs:
%       Y            - Column vector containing the generated pure tone
%       T            - Matching time vector (column vector)


% Validate the input degree and get the corresponding frequency.
if ~isscalar(degree) || degree ~= fix(degree) || degree < 1 || degree > 7
    error('generate_tone:InvalidDegree', ...
        'Degree must be an integer between 1 and 7.');
end


% =========================================================================
% To Do Step 1: the lookup table for the frequency
% =========================================================================
frequencies = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 494.00];

% =========================================================================
% To Do Step 2: Generate a pure sinusoid 
% =========================================================================
freq = frequencies(degree);
[y, t] = generate_sinusoid(sample_rate, freq, amplitude, duration);

end
