function envelope = adsrEnvelope(sampleCount, sampleRate, config)
%ADSRENVELOPE Build a deterministic attack-decay-sustain-release envelope.

    validateattributes(sampleCount, {'numeric'}, ...
        {'scalar', 'integer', 'positive', 'finite'}, mfilename, 'sampleCount');
    validateattributes(sampleRate, {'numeric'}, ...
        {'scalar', 'real', 'positive', 'finite'}, mfilename, 'sampleRate');
    validateattributes(config, {'struct'}, {'scalar'}, mfilename, 'config');

    required = {'attackSeconds', 'decaySeconds', 'sustainLevel', 'releaseSeconds'};
    assert(all(isfield(config, required)), "AirWaveLab:InvalidADSR", ...
        "ADSR config must contain attackSeconds, decaySeconds, " + ...
        "sustainLevel, and releaseSeconds.");
    validateattributes(config.attackSeconds, {'numeric'}, ...
        {'scalar', 'real', 'nonnegative', 'finite'});
    validateattributes(config.decaySeconds, {'numeric'}, ...
        {'scalar', 'real', 'nonnegative', 'finite'});
    validateattributes(config.sustainLevel, {'numeric'}, ...
        {'scalar', 'real', '>=', 0, '<=', 1, 'finite'});
    validateattributes(config.releaseSeconds, {'numeric'}, ...
        {'scalar', 'real', 'nonnegative', 'finite'});

    attackCount = round(config.attackSeconds * sampleRate);
    decayCount = round(config.decaySeconds * sampleRate);
    releaseCount = round(config.releaseSeconds * sampleRate);
    assert(attackCount + decayCount + releaseCount <= sampleCount, ...
        "AirWaveLab:ADSRTooLong", ...
        "Attack, decay, and release must fit inside the signal duration.");

    envelope = config.sustainLevel * ones(sampleCount, 1);
    cursor = 1;
    if attackCount > 0
        if attackCount == 1
            envelope(cursor) = 1;
        else
            envelope(cursor:cursor+attackCount-1) = ...
                linspace(0, 1, attackCount).';
        end
        cursor = cursor + attackCount;
    end
    if decayCount > 0
        decay = linspace(1, config.sustainLevel, decayCount+1).';
        envelope(cursor:cursor+decayCount-1) = decay(2:end);
        cursor = cursor + decayCount;
    end

    releaseStart = sampleCount - releaseCount + 1;
    if cursor < releaseStart
        envelope(cursor:releaseStart-1) = config.sustainLevel;
    end
    if releaseCount > 0
        release = linspace(config.sustainLevel, 0, releaseCount+1).';
        envelope(releaseStart:end) = release(2:end);
    end
end
