function estimate = estimateFundamentalFrequency(signal, frequencyRangeHz)
%ESTIMATEFUNDAMENTALFREQUENCY Estimate pitch from normalized autocorrelation.

    airwavelab.validateSignal(signal);
    validateattributes(frequencyRangeHz, {'numeric'}, ...
        {'vector', 'numel', 2, 'real', 'positive', 'increasing', 'finite'});
    minimumHz = frequencyRangeHz(1);
    maximumHz = frequencyRangeHz(2);
    assert(maximumHz < signal.sampleRate/2, ...
        "AirWaveLab:FrequencyAboveNyquist", ...
        "The maximum search frequency must be below Nyquist.");

    samples = signal.samples - mean(signal.samples);
    sampleCount = numel(samples);
    assert(sampleCount >= ceil(2*signal.sampleRate/minimumHz), ...
        "AirWaveLab:PitchFrameTooShort", ...
        "The signal must contain at least two periods at the minimum frequency.");
    if sampleCount > 1
        window = 0.5 - 0.5*cos(2*pi*(0:sampleCount-1)'/(sampleCount-1));
        samples = samples .* window;
    end
    assert(sum(samples.^2) > eps, "AirWaveLab:PitchUndefined", ...
        "Fundamental frequency is undefined for a constant signal.");

    minimumLag = max(1, floor(signal.sampleRate/maximumHz));
    maximumLag = min(sampleCount-2, ceil(signal.sampleRate/minimumHz));
    nfft = 2^nextpow2(2*sampleCount-1);
    autocorrelation = real(ifft(abs(fft(samples, nfft)).^2));
    correlation = autocorrelation(minimumLag+1:maximumLag+1) / ...
        max(autocorrelation(1), eps);
    lags = reshape(minimumLag:maximumLag, [], 1);
    [peakCorrelation, peakIndex] = max(correlation);

    refinedLag = double(lags(peakIndex));
    if peakIndex > 1 && peakIndex < numel(correlation)
        left = correlation(peakIndex-1);
        center = correlation(peakIndex);
        right = correlation(peakIndex+1);
        denominator = left - 2*center + right;
        if abs(denominator) > eps
            refinedLag = refinedLag + 0.5*(left-right)/denominator;
        end
    end

    estimate = struct( ...
        "frequencyHz", signal.sampleRate/refinedLag, ...
        "periodSeconds", refinedLag/signal.sampleRate, ...
        "lagSamples", refinedLag, ...
        "confidence", peakCorrelation, ...
        "candidateLags", lags, ...
        "correlation", correlation);
end
