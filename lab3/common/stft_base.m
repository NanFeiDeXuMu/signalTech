function [S, f, t, amplitude, info] = stft_base(x, fs, win_len, noverlap, nfft)
%STFT_BASE Symmetric Hamming windows and base-MATLAB FFT.
% S is raw complex one-sided STFT. AMPLITUDE is divided by sum(win)
% and doubled except DC and an even-length Nyquist bin. This is not PSD.
% Complete frames only; times are means of first and last sample times.
validateattributes(x, {'numeric'}, {'vector','real','finite','nonempty'});
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(win_len, {'numeric'}, {'scalar','integer','>=',2});
validateattributes(noverlap, {'numeric'}, {'scalar','integer','nonnegative','<',win_len});
validateattributes(nfft, {'numeric'}, {'scalar','integer','>=',win_len});
x = x(:);
assert(numel(x) >= win_len, 'Lab3:ShortSTFT', 'Input is shorter than a full window.');
win = 0.54 - 0.46*cos(2*pi*(0:win_len-1)'/(win_len-1));
hop = win_len - noverlap;
starts = 1:hop:(numel(x)-win_len+1);
frames = x((0:win_len-1)' + starts) .* win;
Y = fft(frames, nfft, 1);
S = Y(1:floor(nfft/2)+1, :);
amplitude = abs(S) / sum(win);
if mod(nfft, 2) == 0
    amplitude(2:end-1,:) = 2*amplitude(2:end-1,:);
else
    amplitude(2:end,:) = 2*amplitude(2:end,:);
end
f = (0:floor(nfft/2))' * fs/nfft;
t = (starts-1 + (win_len-1)/2) / fs;
info = struct('windowLength',win_len,'overlap',noverlap,'nfft',nfft, ...
    'hopSamples',hop,'windowSeconds',win_len/fs,'hopSeconds',hop/fs, ...
    'binHz',fs/nfft,'frameCount',numel(starts), ...
    'discardedTailSamples',numel(x)-(starts(end)+win_len-1));
end
