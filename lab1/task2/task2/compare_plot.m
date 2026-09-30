function compare_plot(y1, t1, y2, t2, plot_name)
% merge the time scale, take the union of two
t_start = min([t1(1), t2(1)]);
t_end   = max([t1(end), t2(end)]);

% take the proper step size
dt = min([t1(2)-t1(1), t2(2)-t2(1)]);
t_union = t_start : dt : t_end;

% Resample the two signal to the new time scale, if the time scale out of
% the scale time, fill in 0 
y1_resampled = interp1(t1, y1, t_union, 'linear', 0);
y2_resampled = interp1(t2, y2, t_union, 'linear', 0);

% plot
figure;
scatter(t_union, y1_resampled, 10, 'b', 'filled' ); hold on;
scatter(t_union, y2_resampled, 10, 'r', 'filled' ); hold off;
xlabel('Time (s)'); ylabel('Amplitude'); 
title(plot_name);
grid on;
xlim([t_start, t_end]);

end