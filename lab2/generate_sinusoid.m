function [y, t] = generate_sinusoid(sample_rate, freq, amplitude, duration)
% GENERATE_SINUSOID Generate a sampled sinusoidal signal.
%   [Y, T] = GENERATE_SINUSOID(SAMPLE_RATE, FREQ, AMPLITUDE, DURATION)
%   returns the signal and time instants as column vectors. The final time
%   instant is DURATION - 1 / SAMPLE_RATE.

N = sample_rate * duration;
t = (0 : N - 1)' / sample_rate;
y = amplitude * sin(2 * pi * freq * t);

end
