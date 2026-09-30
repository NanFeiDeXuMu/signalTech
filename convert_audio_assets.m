function report = convert_audio_assets(overwrite)
%CONVERT_AUDIO_ASSETS Convert supported files in assets/audio to WAV.

    if nargin < 1
        overwrite = false;
    end
    root = fileparts(mfilename("fullpath"));
    addpath(fullfile(root, "src"));
    report = airwavelab.convertAudioAssets( ...
        string(fullfile(root, "assets", "audio")), overwrite);
    if isempty(report)
        fprintf("No supported non-WAV audio assets found.\n");
    else
        disp(report);
    end
end

