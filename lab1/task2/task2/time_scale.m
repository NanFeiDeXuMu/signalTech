function [y_scaled, t_scaled] = time_scale(y, t, scale_factor)
% TIME_SCALE Compress or expand a signal in time.
%   [Y_SCALED, T_SCALED] = TIME_SCALE(Y, T, SCALE_FACTOR)
%   compresses or expands the input signal Y in time by SCALE_FACTOR
%   and returns the resampled signal and its new time vector.
%
%   Inputs:
%       Y           - Signal vector (column vector) of the original signal
%       T           - Time vector (column vector) of the original signal
%       SCALE_FACTOR - Time scaling factor. 
%                     > 1  : Compress the signal (higher frequency)
%                     0 < SCALE_FACTOR < 1 : Expand the signal (lower frequency)
%
%   Outputs:
%       Y_SCALED    - Scaled signal vector (resampled using linear interpolation)
%       T_SCALED    - Scaled time vector: T * SCALE_FACTOR
%
 
 
% =========================================================================
% Apply time scaling
% =========================================================================
y_scaled = y;
t_scaled = t / scale_factor;

end