function signal = generateSpeechLike(sampleRate, durationSeconds, seed)
%GENERATESPEECHLIKE Generate deterministic voiced audio for demos and tests.

    if nargin < 1
        sampleRate = 16000;
    end
    if nargin < 2
        durationSeconds = 5;
    end
    if nargin < 3
        seed = 1903;
    end

    validateattributes(durationSeconds, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});
    previousState = rng;
    cleanup = onCleanup(@() rng(previousState));
    rng(seed, "twister");

    sampleCount = max(1, round(sampleRate * durationSeconds));
    time = reshape(0:sampleCount-1, [], 1) / sampleRate;
    fundamental = 125 + 22*sin(2*pi*0.65*time) + 8*sin(2*pi*1.7*time);
    phase = cumsum(2*pi*fundamental/sampleRate);

    voiced = zeros(sampleCount, 1);
    for harmonic = 1:7
        voiced = voiced + sin(harmonic*phase + 0.2*harmonic) / harmonic;
    end
    syllables = max(0, sin(2*pi*1.8*time)).^0.65;
    envelope = (0.15 + 0.85*syllables) .* (0.85 + 0.15*sin(2*pi*0.27*time));
    breath = 0.025 * randn(sampleCount, 1) .* envelope;
    samples = voiced .* envelope + breath;
    samples = 0.8 * samples / max(abs(samples));
    signal = airwavelab.createSignal(samples, sampleRate, "synthetic-speech");
end
