%=================================================
% Check the functionality of time shift
%=================================================
% Define the parameters
sample_rate = 1000;   % Sampling rate in Hz
freq = 1;             % Signal frequency in Hz
amplitude = 5;        % Peak amplitude
duration = 2;         % Signal duration in seconds
[y1, t1] = generate_sinusoid(sample_rate, freq, amplitude, duration);
[y2, t2] = time_shift(y1, t1, -2);
compare_plot(y1, t1, y2, t2, 'Signal before and after time shift')

%=================================================
% Check the functionality of amplitude scale
%=================================================
% Define the parameters
sample_rate = 1000;   % Sampling rate in Hz
freq = 1;             % Signal frequency in Hz
amplitude = 5;        % Peak amplitude
duration = 2;         % Signal duration in seconds
[y1, t1] = generate_sinusoid(sample_rate, freq, amplitude, duration);
[y2, t2] = amplitude_scale(y1, t1, -1);
compare_plot(y1, t1, y2, t2, 'Signal before and after amplitude scale')

%=================================================
% Check the functionality of time scale
%=================================================
% Define the parameters
sample_rate = 1000;   % Sampling rate in Hz
freq = 1;             % Signal frequency in Hz
amplitude = 5;        % Peak amplitude
duration = 2;         % Signal duration in seconds
[y1, t1] = generate_sinusoid(sample_rate, freq, amplitude, duration);
[y2, t2] = time_scale(y1, t1, 2);
compare_plot(y1, t1, y2, t2, 'Signal before and after time scale')


%=================================================
% Check the functionality of time inversion
%=================================================
% Define the parameters
sample_rate = 1000;   % Sampling rate in Hz
freq = 1;             % Signal frequency in Hz
amplitude = 5;        % Peak amplitude
duration = 2;         % Signal duration in seconds
[y1, t1] = generate_sinusoid(sample_rate, freq, amplitude, duration);
[y2, t2] = time_invert(y1, t1);
compare_plot(y1, t1, y2, t2, 'Signal before and after time inversion')


%=================================================
% Check the functionality of signal addition
%=================================================
% Define the common parameters
sample_rate = 1000;   % Sampling rate in Hz
duration = 2;         % Signal duration in seconds
% Define the parameters for signal 1
freq = 1;             % Signal frequency in Hz
amplitude = 5;        % Peak amplitude
[y1, t1] = generate_sinusoid(sample_rate, freq, amplitude, duration);
% Define the parameters for signal 2
freq = 3 ;             % Signal frequency in Hz
amplitude = 2;        % Peak amplitude 
[y2, t2] = generate_sinusoid(sample_rate, freq, amplitude, duration);
[y3, t3] = signal_add(y1, t1, y2, t2);
compare_plot3(y1, t1, y2, t2, y3, t3, 'Signal before and after addition')


%=================================================
% Check the functionality of signal multiplication
%=================================================
% Define the common parameters
sample_rate = 1000;   % Sampling rate in Hz
duration = 2;         % Signal duration in seconds
% Define the parameters for signal 1
freq = 1;             % Signal frequency in Hz
amplitude = 5;        % Peak amplitude
[y1, t1] = generate_sinusoid(sample_rate, freq, amplitude, duration);
% Define the parameters for signal 2
freq = 3 ;             % Signal frequency in Hz
amplitude = 2;        % Peak amplitude 
[y2, t2] = generate_sinusoid(sample_rate, freq, amplitude, duration);
[y3, t3] = signal_multiply(y1, t1, y2, t2);
compare_plot3(y1, t1, y2, t2, y3, t3, 'Signal before and after multiplication')