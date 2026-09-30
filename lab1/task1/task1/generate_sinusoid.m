function [y,t] = generate_sinusoid(sample_rate, freq, amplitude, duration)
% GENERATE_SINUSOID Generate a discrete-time sinusoidal signal.
%   [Y, T] = GENERATE_SINUSOID(SAMPLE_RATE, FREQ, AMPLITUDE, DURATION)
%   generates a column vector Y representing the sampled sinusoid, and a
%   corresponding time column vector T.
%
%   Inputs:
%       SAMPLE_RATE - Number of samples per second.
%       FREQ        - Frequency of the sinusoid in Hz
%       AMPLITUDE   - Peak amplitude of the sinusoid
%       DURATION    - Total signal duration in seconds
%
%   Output:
%       Y           - Column vector of Amplitude.
%       T           - Column vector of time instants.
%


% =========================================================================
% To Do Step 1: Create the time base. 
% =========================================================================
N = sample_rate * duration;
t = (0 : N - 1)' / sample_rate;

% =========================================================================
% To Do Step 2: Generate the sinusoid using the given frequency and amplitude. 
% =========================================================================
y = amplitude * sin(2 * pi * freq * t);

end
