function result = frequency_analysis(cfg)
%FREQUENCY_ANALYSIS Task 2: WAV-based FFT and time-frequency experiments.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'common'));
if nargin < 1, cfg = lab3_config(); end
[plain,fs] = audioread(fullfile(cfg.output_dir,'task2_harmonic_melody.wav'));
[shaped,fs2] = audioread(fullfile(cfg.output_dir,'task2_timbre_melody.wav'));
assert(fs == fs2 && isequal(size(plain),size(shaped)), 'Lab3:InputMismatch', ...
    'The comparison WAVs must have identical rates and dimensions.');
notes = readtable(fullfile(cfg.output_dir,'notes.csv'));
assert(size(plain,2)==1 && notes.EndSample(end)==numel(plain));
waves = {plain,shaped};
labels = {'Harmonics only','Harmonics + envelope'};
fig = lab3_figure(cfg,'Whole-melody FFT',500);
layout = tiledlayout(fig,2,1,'TileSpacing','compact','Padding','compact');
for col = 1:2
    ax = nexttile(layout);
    draw_spectrum(ax,waves{col},fs,cfg.frequency_limit);
    ylim(ax,[0,0.11]); title(ax,[labels{col},' | full 6.4 s | N = 51200']);
end
save_lab3_figure(fig,cfg,'fft_full.png');

selected = [1,3,5]; note_names = {'Do','Sol','La'};
fig = lab3_figure(cfg,'Individual-note FFT',780);
layout = tiledlayout(fig,3,2,'TileSpacing','compact','Padding','compact');
peak_rows = cell(0,7);
for row = 1:3
    j = selected(row); idx = notes.StartSample(j):notes.EndSample(j);
    for col = 1:2
        ax = nexttile(layout);
        [f,a] = draw_spectrum(ax,waves{col}(idx),fs,cfg.frequency_limit);
        ylim(ax,[0,0.37]);
        title(ax,sprintf('%s: %.2f Hz | %s',note_names{row},notes.FundamentalHz(j),labels{col}));
        for h = 1:5
            expected = h*notes.FundamentalHz(j);
            candidates = find(abs(f-expected) <= 2*fs/numel(idx));
            [peak,loc] = max(a(candidates)); observed = f(candidates(loc));
            peak_rows(end+1,:) = {labels{col},j,h,expected,observed, ... %#ok<AGROW>
                observed-expected,peak};
        end
    end
end
save_lab3_figure(fig,cfg,'fft_notes.png');
peaks = cell2table(peak_rows,'VariableNames',{'Variant','NoteIndex','Harmonic', ...
    'ExpectedHz','PeakBinHz','ErrorHz','PeakAmplitude'});
writetable(peaks,fullfile(cfg.output_dir,'harmonic_peaks.csv'));

fig = lab3_figure(cfg,'FFT segment-length experiment',780);
layout = tiledlayout(fig,3,2,'TileSpacing','compact','Padding','compact');
durations = [0.05,0.20,0.40];
for row = 1:3
    N = round(durations(row)*fs);
    idx = notes.StartSample(1)+(0:N-1);
    for col = 1:2
        ax = nexttile(layout);
        draw_spectrum(ax,waves{col}(idx),fs,1600);
        ylim(ax,[0,0.37]);
        title(ax,sprintf('%s | %.2f s | grid %.1f Hz',labels{col},N/fs,fs/N));
    end
end
save_lab3_figure(fig,cfg,'fft_lengths.png');

% Baseline uses the supplied template's window / overlap / FFT settings.
fig = lab3_figure(cfg,'Two-dimensional STFT comparison',650);
layout = tiledlayout(fig,2,1,'TileSpacing','compact','Padding','compact');
base = cell(1,2);
for col = 1:2
    [~,f,t,a,info] = stft_base(waves{col},fs,2048,0,4096);
    base{col} = struct('frequency',f,'time',t,'amplitude',a);
    ax = nexttile(layout);
    draw_tf(ax,t,f,a,cfg);
    title(ax,[labels{col},' | L=2048, overlap=0, FFT=4096']);
end
save_lab3_figure(fig,cfg,'spectrogram_compare.png');
fig = lab3_figure(cfg,'Three-dimensional STFT comparison',500);
layout = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
for col = 1:2
    ax = nexttile(layout);
    b = base{col};
    % Frequency decimation affects rendering only, not the saved STFT data.
    idx = find(b.frequency <= cfg.frequency_limit);
    idx = idx(1:4:end);
    waterfall(ax,b.time,b.frequency(idx),20*log10(max(b.amplitude(idx,:),1e-4)));
    view(ax,40,35); xlim(ax,[0,numel(plain)/fs]); ylim(ax,[0,cfg.frequency_limit]);
    zlim(ax,cfg.db_limits); clim(ax,cfg.db_limits); colormap(ax,parula);
    xlabel(ax,'Time (s)'); ylabel(ax,'Frequency (Hz)'); zlabel(ax,'Amplitude (dB re 1)');
    title(ax,labels{col});
end
save_lab3_figure(fig,cfg,'waterfall_compare.png');
experiment_rows = { 'Baseline', info.windowLength, info.overlap, info.nfft, ...
    info.windowSeconds,info.hopSeconds,info.binHz,info.frameCount,info.discardedTailSamples };
settings = {[256,128,4096;1024,512,4096;2048,1024,4096], ...
    [1024,0,4096;1024,512,4096;1024,768,4096], ...
    [1024,512,1024;1024,512,2048;1024,512,4096]};
group_names = {'Window length','Overlap','FFT points'};
filenames = {'sweep_window.png','sweep_overlap.png','sweep_nfft.png'};
for group = 1:3
    fig = lab3_figure(cfg,group_names{group},780);
    columns = 1 + (group==3);
    layout = tiledlayout(fig,3,columns,'TileSpacing','compact','Padding','compact');
    for row = 1:3
        p = settings{group}(row,:);
        [~,f,t,a,info] = stft_base(shaped,fs,p(1),p(2),p(3));
        ax = nexttile(layout);
        draw_tf(ax,t,f,a,cfg);
        title(ax,sprintf('L=%d, overlap=%d, FFT=%d | hop %.0f ms | grid %.3f Hz', ...
            p(1),p(2),p(3),1000*info.hopSeconds,info.binHz));
        if group == 3
            ax = nexttile(layout);
            plot(ax,f,a(:,1),'.-','MarkerSize',8); xlim(ax,[180,340]);
            ylim(ax,[0,0.30]); grid(ax,'on');
            xlabel(ax,'Frequency (Hz)'); ylabel(ax,'Amplitude');
            title(ax,'Same first frame, different FFT grid');
        end
        experiment_rows(end+1,:) = {group_names{group},p(1),p(2),p(3), ... %#ok<AGROW>
            info.windowSeconds,info.hopSeconds,info.binHz,info.frameCount,info.discardedTailSamples};
    end
    save_lab3_figure(fig,cfg,filenames{group});
end
experiments = cell2table(experiment_rows,'VariableNames',{'Experiment','WindowSamples', ...
    'OverlapSamples','FFTPoints','WindowSeconds','HopSeconds','BinHz','Frames','DiscardedTailSamples'});
writetable(experiments,fullfile(cfg.output_dir,'stft_experiments.csv'));
save(fullfile(cfg.output_dir,'stft_baseline.mat'),'base','fs');
result = struct('peaks',peaks,'experiments',experiments);
fprintf('Saved FFT, STFT, waterfall and all three parameter sweeps.\n');
end

function [f,a] = draw_spectrum(ax,y,fs,limit)
[f,a] = single_sided_spectrum(y,fs);
plot(ax,f,a,'LineWidth',1);
xlim(ax,[0,limit]); grid(ax,'on');
xlabel(ax,'Frequency (Hz)'); ylabel(ax,'Amplitude');
end

function draw_tf(ax,t,f,a,cfg)
imagesc(ax,t,f,20*log10(max(a,1e-4)));
axis(ax,'xy'); ylim(ax,[0,cfg.frequency_limit]);
clim(ax,cfg.db_limits); colormap(ax,parula);
bar = colorbar(ax); bar.Label.String = 'Amplitude (dB re 1)';
xlabel(ax,'Time (s)'); ylabel(ax,'Frequency (Hz)');
end
