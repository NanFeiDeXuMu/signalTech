function [y_product, t_out] = signal_multiply(y1, t1, y2, t2)
% SIGNAL_MULTIPLY Multiply two signals point-by-point.
%   [Y_PRODUCT, T_OUT] = SIGNAL_MULTIPLY(Y1, T1, Y2, T2)
%   multiplies two signals Y1 and Y2 element-wise and returns the
%   resulting signal. Both signals must have the same length.
%
%   Inputs:
%       Y1          - Signal vector of the first signal
%       T1          - Time vector of the first signal
%       Y2          - Signal vector of the second signal
%       T2          - Time vector of the second signal
%
%   Outputs:
%       Y_PRODUCT   - Product signal: y_product[n] = y1[n] * y2[n]
%       T_OUT       - Time vector (same as T1, assuming T1 == T2)
%
 
% =========================================================================
% Apply multiplication
% =========================================================================
y_product = y1 .* y2;
t_out = t1;
end