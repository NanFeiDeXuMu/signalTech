clearvars;
close all;
clc;
%=================================================
% Assignment 2: sinusoid -> sound (Song A)
%=================================================

sample_rate = 8000;   % Hz
amplitude   = 0.4;
beat_sec    = 0.4;    % duration of one beat in seconds

% Song A: 1 1 5 5 | 6 6 5 - | 4 4 3 3 | 2 2 1 -
note_degrees = [1, 1, 5, 5, 6, 6, 5, 4, 4, 3, 3, 2, 2, 1];
note_beats   = [1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2];

note_lengths = round(note_beats * beat_sec * sample_rate);
attack_sec = 0.01;
release_sec = beat_sec * 0.3;
attack_samples = round(attack_sec * sample_rate);
release_samples = round(release_sec * sample_rate);

% Release tails overlap subsequent notes, so the score timing is preserved.
melody = zeros(sum(note_lengths) + release_samples, 1);
write_index = 1;

for k = 1:numel(note_degrees)
    note_duration = note_beats(k) * beat_sec;
    sounding_duration = note_duration + release_sec;
    tone = generate_tone(note_degrees(k), sample_rate, amplitude, ...
        sounding_duration);

    envelope = ones(size(tone));
    attack_position = linspace(0, 1, attack_samples)';
    release_position = linspace(0, 1, release_samples)';
    envelope(1 : attack_samples) = sin(pi / 2 * attack_position).^2;
    envelope(end - release_samples + 1 : end) = ...
        cos(pi / 2 * release_position).^2;
    tone = tone .* envelope;

    final_index = write_index + numel(tone) - 1;
    melody(write_index : final_index) = ...
        melody(write_index : final_index) + tone;

    % Advance by the score duration only, allowing the release to overlap.
    write_index = write_index + note_lengths(k);
end

% Prevent clipping if overlapping tones exceed the valid audio range.
peak_amplitude = max(abs(melody));
if peak_amplitude > 0.99
    melody = 0.99 * melody / peak_amplitude;
end

melody_t = (0 : numel(melody) - 1)' / sample_rate;
total_duration = numel(melody) / sample_rate;

% Save the audio file and a waveform image for the report.
script_dir = fileparts(mfilename('fullpath'));
output_dir = fullfile(script_dir, 'output');
if ~isfolder(output_dir)
    mkdir(output_dir);
end
audio_path = fullfile(output_dir, 'task1_pure_sine_melody.wav');
audiowrite(audio_path, melody, sample_rate);

% Plot a short excerpt
excerpt_duration = 0.5;
excerpt_samples = min(round(excerpt_duration * sample_rate), numel(melody));
figure('Color', 'white', 'Position', [100, 100, 900, 520]);
plot(melody_t(1 : excerpt_samples), melody(1 : excerpt_samples), ...
    'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Amplitude');
title('Assignment 2: Song A pure-sine waveform excerpt');
grid on;
xlim([0, excerpt_duration]);
ylim([-0.5, 0.5]);

figure_path = fullfile(output_dir, 'task1_melody_excerpt.png');
exportgraphics(gcf, figure_path, 'Resolution', 200);

fprintf('Song A complete: %.2f s, %d samples.\n', ...
    total_duration, numel(melody));
fprintf('Saved %s\n', audio_path);
% sound(melody, sample_rate);   % uncomment to listen in MATLAB
