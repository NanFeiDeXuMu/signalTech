function cfg = lab3_config(output_dir)
%LAB3_CONFIG Reproducible score and rendering settings.
root = fileparts(fileparts(mfilename('fullpath')));
if nargin < 1 || isempty(output_dir), output_dir = fullfile(root, 'output'); end
cfg.output_dir = char(output_dir);
cfg.sample_rate = 8000;
cfg.amplitude = 0.35;
cfg.beat_sec = 0.4;
cfg.harmonic_amps = [1, 0.45, 0.25, 0.12, 0.06];
cfg.note_degrees = [1, 1, 5, 5, 6, 6, 5, 4, 4, 3, 3, 2, 2, 1];
cfg.note_beats = [1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2];
cfg.figure_visible = 'off';
cfg.db_limits = [-80, 0];
cfg.frequency_limit = 2600;
cfg.seed = 1903;
end
