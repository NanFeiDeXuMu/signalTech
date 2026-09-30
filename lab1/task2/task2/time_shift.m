function [y_out, t_shifted] = time_shift(y, t, shift_time)
% TIME_SHIFT Shift a signal in time by a specified amount.
%   [Y_SHIFTED, T_SHIFTED] = TIME_SHIFT(Y, T, SHIFT_TIME)
%   shifts the input signal Y by SHIFT_TIME seconds and returns the
%   shifted signal values and time vector.
%
%   Inputs:
%       Y           - Signal vector (column vector) of the original signal
%       T           - Time vector (column vector) of the original signal
%       SHIFT_TIME  - Amount of time shift (in seconds)
%
%   Outputs:
%       Y_OUT   - Shifted signal vector (values unchanged)
%       T_SHIFTED   - Shifted time vector 
%

% =========================================================================
% To Do : Apply time shift
% =========================================================================
y_out = y;
t_shifted = t + shift_time;

end