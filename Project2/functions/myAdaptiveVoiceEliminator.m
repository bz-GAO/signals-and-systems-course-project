function [y, model] = myAdaptiveVoiceEliminator(x, Fs, options)
%MYADAPTIVEVOICEELIMINATOR Compensate small L/R gain and delay mismatch.
%   Ordinary L-R cancellation assumes that a centre source has identical
%   gain and phase in both channels. This function estimates a short delay
%   and scalar gain from speech-band content, aligns the right channel, and
%   uses the compensated subtraction only inside a smoothly tapered speech
%   band. It remains a centre-cancellation method, not source separation.

    if nargin < 3
        options = struct();
    end
    if size(x, 2) ~= 2
        error('Input must be a two-channel stereo signal.');
    end

    lowCutoff = getOption(options, 'lowCutoff', 120);
    highCutoff = getOption(options, 'highCutoff', min(6000, 0.45 * Fs));
    maxDelaySamples = getOption(options, 'maxDelaySamples', 8);
    maxGainDb = getOption(options, 'maxGainDb', 6);

    left = x(:, 1);
    right = x(:, 2);
    leftBand = idealBandPass(left, Fs, lowCutoff, highCutoff);
    rightBand = idealBandPass(right, Fs, lowCutoff, highCutoff);

    candidateDelays = -maxDelaySamples:maxDelaySamples;
    scores = zeros(size(candidateDelays));
    for delayIndex = 1:length(candidateDelays)
        alignedRight = shiftWithZeros(rightBand, candidateDelays(delayIndex));
        scores(delayIndex) = dot(leftBand, alignedRight) ...
            / sqrt((dot(leftBand, leftBand) + eps) ...
            * (dot(alignedRight, alignedRight) + eps));
    end
    [~, bestIndex] = max(scores);
    delaySamples = candidateDelays(bestIndex);

    alignedRightBand = shiftWithZeros(rightBand, delaySamples);
    % Energy matching is less biased than a least-squares coefficient when
    % the two channels also contain substantial decorrelated accompaniment.
    gain = sqrt((dot(leftBand, leftBand) + eps) ...
        / (dot(alignedRightBand, alignedRightBand) + eps));
    gainLimit = 10^(maxGainDb / 20);
    gain = min(max(gain, 1 / gainLimit), gainLimit);
    % A small dead band prevents harmless channel-energy differences from
    % degrading the exact L-R solution when the source is already centred.
    if abs(20 * log10(gain)) < 0.5
        gain = 1;
    end

    alignedRight = shiftWithZeros(right, delaySamples);
    basic = left - right;
    compensated = left - gain * alignedRight;

    sampleCount = length(left);
    frequency = (0:sampleCount-1)' * Fs / sampleCount;
    absoluteFrequency = min(frequency, Fs - frequency);
    lowerTransition = max(30, 0.25 * lowCutoff);
    upperTransition = max(200, 0.10 * highCutoff);
    lowerWeight = 0.5 * (1 + tanh((absoluteFrequency - lowCutoff) / lowerTransition));
    upperWeight = 0.5 * (1 - tanh((absoluteFrequency - highCutoff) / upperTransition));
    speechBandWeight = lowerWeight .* upperWeight;

    Y = (1 - speechBandWeight) .* fft(basic) ...
        + speechBandWeight .* fft(compensated);
    y = real(ifft(Y));

    model = struct();
    model.Fs = Fs;
    model.lowCutoff = lowCutoff;
    model.highCutoff = highCutoff;
    model.delaySamples = delaySamples;
    model.gain = gain;
    model.speechBandWeight = speechBandWeight;
    model.correlationScores = scores;
    model.candidateDelays = candidateDelays;
end

function filtered = idealBandPass(signal, Fs, lowCutoff, highCutoff)
    sampleCount = length(signal);
    frequency = (0:sampleCount-1)' * Fs / sampleCount;
    absoluteFrequency = min(frequency, Fs - frequency);
    mask = absoluteFrequency >= lowCutoff & absoluteFrequency <= highCutoff;
    filtered = real(ifft(fft(signal(:)) .* mask));
end

function shifted = shiftWithZeros(signal, delaySamples)
% Positive values advance the signal; negative values delay it.
    signal = signal(:);
    if delaySamples > 0
        shifted = [signal(delaySamples+1:end); zeros(delaySamples, 1)];
    elseif delaySamples < 0
        amount = -delaySamples;
        shifted = [zeros(amount, 1); signal(1:end-amount)];
    else
        shifted = signal;
    end
end

function value = getOption(options, name, defaultValue)
    if isfield(options, name)
        value = options.(name);
    else
        value = defaultValue;
    end
end
