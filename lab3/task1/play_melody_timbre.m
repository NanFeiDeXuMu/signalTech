function result = play_melody_timbre(cfg)
%PLAY_MELODY_TIMBRE Task 1: synthesize Song A and save both WAVs and plots.
% No automatic playback in batch mode. Listen with sound(y,fs) or the WAVs.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'common'));
if nargin < 1, cfg = lab3_config(); end
if ~isfolder(cfg.output_dir), mkdir(cfg.output_dir); end
fs = cfg.sample_rate;
lengths = round(cfg.note_beats(:) * cfg.beat_sec * fs);
starts = [1; 1+cumsum(lengths(1:end-1))];
ends = cumsum(lengths);
harmonic = zeros(sum(lengths),1);
timbre = harmonic;
f0 = zeros(numel(lengths),1);
for j = 1:numel(lengths)
    [tone, ~, f0(j)] = generate_harmonic_tone(cfg.note_degrees(j), fs, ...
        cfg.amplitude, lengths(j)/fs, cfg.harmonic_amps);
    envelope = generate_piano_envelope(lengths(j));
    harmonic(starts(j):ends(j)) = tone;
    timbre(starts(j):ends(j)) = tone .* envelope;
end
assert(max(abs([harmonic;timbre])) < 1, 'Lab3:Clipping', 'Reduce the common gain.');
notes = table((1:numel(lengths))', cfg.note_degrees(:), f0, cfg.note_beats(:), ...
    starts, ends, (starts-1)/fs, lengths/fs, 'VariableNames', ...
    {'NoteIndex','Degree','FundamentalHz','Beats','StartSample','EndSample', ...
    'StartSeconds','DurationSeconds'});
writetable(notes, fullfile(cfg.output_dir,'notes.csv'));
names = {'task2_harmonic_melody.wav','task2_timbre_melody.wav'};
waves = {harmonic,timbre};
peak = zeros(2,1); rms_value = peak; wav_error = peak; boundary_jump = peak;
for k = 1:2
    audiowrite(fullfile(cfg.output_dir,names{k}), waves{k}, fs, 'BitsPerSample',24);
    [readback, read_fs] = audioread(fullfile(cfg.output_dir,names{k}));
    assert(read_fs == fs && numel(readback) == sum(lengths));
    wav_error(k) = max(abs(readback-waves{k}));
    peak(k) = max(abs(waves{k}));
    rms_value(k) = sqrt(mean(waves{k}.^2));
    boundary_jump(k) = max(abs(waves{k}(starts(2:end))-waves{k}(starts(2:end)-1)));
end
metrics = table({'Harmonics only';'Harmonics + envelope'}, ...
    repmat(sum(lengths),2,1),repmat(sum(lengths)/fs,2,1),peak,rms_value, ...
    boundary_jump,wav_error,'VariableNames',{'Variant','Samples','DurationSeconds', ...
    'Peak','RMS','MaxBoundaryJump','MaxWavError'});
writetable(metrics, fullfile(cfg.output_dir,'audio_metrics.csv'));
t = (0:numel(harmonic)-1)'/fs;
fig = lab3_figure(cfg,'Task 1: waveforms',820);
layout = tiledlayout(fig,3,2,'TileSpacing','compact','Padding','compact');
labels = {'Harmonics only','Harmonics + envelope'};
intervals = [0,numel(harmonic)/fs;0,1.2;0.08,0.10];
for row = 1:3
    for col = 1:2
        ax = nexttile(layout);
        idx = t >= intervals(row,1) & t < intervals(row,2);
        plot(ax,t(idx),waves{col}(idx),'LineWidth',0.7);
        xlim(ax,intervals(row,:)); ylim(ax,[-0.55,0.55]); grid(ax,'on');
        xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude');
        title(ax,labels{col});
    end
end
save_lab3_figure(fig,cfg,'task1_waveforms.png');
fig = lab3_figure(cfg,'Task 1: hit envelope',350);
e = generate_piano_envelope(lengths(1));
plot((0:numel(e)-1)/fs,e,'LineWidth',2,'Color',[0.8,0.25,0.1]);
xlabel('Time within note (s)'); ylabel('Gain'); grid on;
title('5% linear attack, 95% squared decay (0.4 s note)');
ylim([0,1.05]); xlim([0,lengths(1)/fs]);
save_lab3_figure(fig,cfg,'task1_envelope.png');
result = struct('harmonic',harmonic,'timbre',timbre,'notes',notes,'metrics',metrics);
disp(metrics);
end
