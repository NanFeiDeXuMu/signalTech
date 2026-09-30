function [y_inverted, t_inverted] = time_invert(y, t)
% TIME_INVERT Reverse (flip) a signal in time.
%   [Y_INVERTED, T_INVERTED] = TIME_INVERT(Y, T)
%   reverses the input signal Y in time and returns the flipped
%   signal and its corresponding time vector.
%
%   Inputs:
%       Y           - Signal vector (column vector) of the original signal
%       T           - Time vector (column vector) of the original signal
%
%   Outputs:
%       Y_INVERTED  - Inverted signal vector (flipped vertically in time)
%       T_INVERTED  - Inverted time vector: -flipud(T)
 

% =========================================================================
% Apply time inversion
% =========================================================================
y_inverted = flipud(y);
t_inverted = -flipud(t);

end
