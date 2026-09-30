function envelope = generate_piano_envelope(num_samples)
%GENERATE_PIANO_ENVELOPE Approximately 5% linear attack, 95% squared decay.
% N=1 or N=2 returns silence; a hit with two zero endpoints needs N>=3.
validateattributes(num_samples, {'numeric'}, {'scalar','integer','finite','positive'});
if num_samples < 3
    envelope = zeros(num_samples, 1);
    return
end
attack_len = max(2, min(num_samples-1, round(0.05*num_samples)));
decay_len = num_samples - attack_len;
attack = linspace(0, 1, attack_len)';
if decay_len == 1
    decay = 0;
else
    decay = linspace(1, 0, decay_len)'.^2;
end
envelope = [attack; decay];
end
