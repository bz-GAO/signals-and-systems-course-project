function yFiltered = myIdealLPF(Y, Fs, cutoff)
%MYIDEALLPF Apply an ideal zero-phase low-pass mask in the DFT domain.

    sampleCount = length(Y);
    shiftedSpectrum = fftshift(Y(:));
    frequency = ((-floor(sampleCount / 2)):(ceil(sampleCount / 2) - 1))' ...
        * (Fs / sampleCount);
    mask = abs(frequency) <= cutoff;
    yFiltered = real(ifft(ifftshift(shiftedSpectrum .* mask)));
end
