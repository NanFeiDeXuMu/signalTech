function [y_sum, t_out] = signal_add(y1, t1, y2, t2)
% SIGNAL_ADD Add two signals point-by-point.
%   [Y_SUM, T_OUT] = SIGNAL_ADD(Y1, T1, Y2, T2)
%   adds two signals Y1 and Y2 and returns the resulting signal.
%   Both signals must have the same length.
%
%   Inputs:
%       Y1          - Signal vector of the first signal
%       T1          - Time vector of the first signal
%       Y2          - Signal vector of the second signal
%       T2          - Time vector of the second signal
%
%   Outputs:
%       Y_SUM       - Sum signal: y_sum[n] = y1[n] + y2[n]
%       T_OUT       - Time vector (same as T1, assuming T1 == T2)
%
 

 
% =========================================================================
% Apply addition
% =========================================================================
y_sum = y1 + y2;
t_out = t1;

end