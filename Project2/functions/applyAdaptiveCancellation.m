function y = applyAdaptiveCancellation(x, model)
%APPLYADAPTIVECANCELLATION Apply an estimated gain-delay model unchanged.
%   Used by the benchmark to process the known vocal and accompaniment
%   components with exactly the same linear operator as the mixture.

    if size(x, 2) ~= 2
        error('Input must be a two-channel stereo signal.');
    end
    if size(x, 1) ~= length(model.speechBandWeight)
        error('Signal length is incompatible with the stored model.');
    end

    left = x(:, 1);
    right = x(:, 2);
    alignedRight = shiftWithZeros(right, model.delaySamples);
    basic = left - right;
    compensated = left - model.gain * alignedRight;
    Y = (1 - model.speechBandWeight) .* fft(basic) ...
        + model.speechBandWeight .* fft(compensated);
    y = real(ifft(Y));
end

function shifted = shiftWithZeros(signal, delaySamples)
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
