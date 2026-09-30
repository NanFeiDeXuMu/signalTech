function [f, amplitude] = single_sided_spectrum(y, fs)
%SINGLE_SIDED_SPECTRUM Rectangular-window FFT, peak-amplitude normalization.
validateattributes(y, {'numeric'}, {'vector','real','finite','nonempty'});
validateattributes(fs, {'numeric'}, {'scalar','finite','real','positive'});
y = y(:);
N = numel(y);
Y = fft(y);
amplitude = abs(Y(1:floor(N/2)+1)) / N;
if mod(N, 2) == 0
    amplitude(2:end-1) = 2*amplitude(2:end-1);
else
    amplitude(2:end) = 2*amplitude(2:end);
end
f = (0:floor(N/2))' * fs/N;
end
