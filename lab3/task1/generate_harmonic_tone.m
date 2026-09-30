function [y, t, f0] = generate_harmonic_tone(degree, sample_rate, amplitude, duration, harmonic_amps)
%GENERATE_HARMONIC_TONE Weighted harmonics of a C-major scale note.
% Outputs are columns; duration is rounded to the nearest sample.
if nargin < 5, harmonic_amps = [1.00, 0.45, 0.25, 0.12, 0.06]; end
validateattributes(degree, {'numeric'}, {'scalar','integer','>=',1,'<=',7});
validateattributes(sample_rate, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(amplitude, {'numeric'}, {'scalar','real','finite','nonnegative'});
validateattributes(duration, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(harmonic_amps, {'numeric'}, {'vector','real','finite','nonnegative','nonempty'});
frequencies = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 494.00];
f0 = frequencies(degree);
active = find(harmonic_amps > 0);
assert(isempty(active) || max(active)*f0 < sample_rate/2, ...
    'Lab3:Aliasing', 'An active harmonic reaches or exceeds Nyquist.');
N = round(sample_rate * duration);
assert(N >= 1, 'Lab3:TooShort', 'Duration must contain at least one sample.');
t = (0:N-1)' / sample_rate;
y = zeros(N, 1);
for k = 1:numel(harmonic_amps)
    y = y + amplitude * harmonic_amps(k) * sin(2*pi*k*f0*t);
end
end
