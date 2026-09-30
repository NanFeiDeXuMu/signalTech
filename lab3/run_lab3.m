function result = run_lab3(output_dir)
%RUN_LAB3 Reproduce both assignment tasks using base MATLAB.
% From the repository root: addpath('lab3'); result = run_lab3;
% Optional OUTPUT_DIR selects a separate result directory.
root = fileparts(mfilename('fullpath'));
previous_path = path;
restore = onCleanup(@() path(previous_path)); %#ok<NASGU>
addpath(fullfile(root,'common'),fullfile(root,'task1'),fullfile(root,'task2'));
if nargin < 1, output_dir = []; end
cfg = lab3_config(output_dir);
previous_rng = rng;
restore_rng = onCleanup(@() rng(previous_rng)); %#ok<NASGU>
rng(cfg.seed,'twister');
synthesis = play_melody_timbre(cfg);
analysis = frequency_analysis(cfg);
result = struct('config',cfg,'synthesis',synthesis,'analysis',analysis);
fprintf('Lab 3 complete. Output: %s\n',cfg.output_dir);
end
