function [y_scaled, t_out] = amplitude_scale(y, t, scale_factor)
% AMPLITUDE_SCALE Scale the amplitude of a signal.
%   [Y_SCALED, T_OUT] = AMPLITUDE_SCALE(Y, T, SCALE_FACTOR)
%   multiplies the input signal Y by SCALE_FACTOR and returns the
%   scaled signal with the original time vector.
%
%   Inputs:
%       Y           - Signal vector (column vector) of the original signal
%       T           - Time vector (column vector) of the original signal
%       SCALE_FACTOR - Multiplication factor. Positive values preserve
%                     the signal polarity; negative values invert (flip) it.
%
%   Outputs:
%       Y_SCALED    - Scaled signal vector
%       T_OUT       - Original time vector (unchanged)


% =========================================================================
% TO DO: Apply amplitude scaling
% =========================================================================
y_scaled = scale_factor * y;
t_out = t;

end