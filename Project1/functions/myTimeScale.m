function [scaledSignal, scaledTime] = myTimeScale(signal, Fs, scaleFactor)
%MYTIMESCALE Approximate f(a t) on the original sampling grid.
%   Linear interpolation implements the time mapping. For compression
%   (a > 1), this elementary implementation does not add an anti-aliasing
%   prefilter; that limitation is discussed in the report.

    if scaleFactor <= 0
        error('scaleFactor must be positive.');
    end
    signal = signal(:);
    sampleCount = length(signal);
    originalTime = (0:sampleCount-1)' / Fs;
    newSampleCount = floor((sampleCount - 1) / scaleFactor) + 1;
    scaledTime = (0:newSampleCount-1)' / Fs;
    queryTime = scaleFactor * scaledTime;
    scaledSignal = interp1(originalTime, signal, queryTime, 'linear', 0);
end
