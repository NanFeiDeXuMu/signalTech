% Compare sinusoidal signals using one parameter change at a time.
configurations = [
    struct('sample_rate', 1000, 'freq', 1, 'amplitude', 5, ...
           'duration', 2, 'file_name', 'task1_baseline.png');
    struct('sample_rate', 1000, 'freq', 1, 'amplitude', 2, ...
           'duration', 2, 'file_name', 'task1_lower_amplitude.png');
    struct('sample_rate', 1000, 'freq', 3, 'amplitude', 5, ...
           'duration', 2, 'file_name', 'task1_higher_frequency.png');
    struct('sample_rate', 8, 'freq', 1, 'amplitude', 5, ...
           'duration', 2, 'file_name', 'task1_lower_sample_rate.png')
];

script_dir = fileparts(mfilename('fullpath'));
figure_dir = fullfile(script_dir, '..', '..', 'figures');
if ~isfolder(figure_dir)
    mkdir(figure_dir);
end

for k = 1:numel(configurations)
    config = configurations(k);
    [y, t] = generate_sinusoid(config.sample_rate, config.freq, ...
        config.amplitude, config.duration);

    figure('Color', 'white', 'Position', [100, 100, 900, 520]);
    if config.sample_rate <= 50
        stem(t, y, 'filled', 'LineWidth', 1.2, 'MarkerSize', 4);
    else
        scatter(t, y, 10, 'filled');
    end
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Sinusoid Signal (f_s = %g Hz, f = %g Hz, A = %g, T = %g s)', ...
        config.sample_rate, config.freq, config.amplitude, config.duration));
    grid on;
    xlim([0, config.duration]);

    exportgraphics(gcf, fullfile(figure_dir, config.file_name), ...
        'Resolution', 200);
end
