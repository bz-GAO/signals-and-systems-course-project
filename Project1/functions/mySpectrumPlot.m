function [Y, frequency] = mySpectrumPlot(y, Fs, plotTitle, subplotPosition)
%MYSPECTRUMPLOT Compute a DFT and plot its normalized two-sided magnitude.

    y = y(:);
    sampleCount = length(y);
    Y = fft(y);
    shiftedSpectrum = fftshift(Y);
    frequency = ((-floor(sampleCount / 2)):(ceil(sampleCount / 2) - 1))' ...
        * (Fs / sampleCount);

    subplot(subplotPosition(1), subplotPosition(2), subplotPosition(3));
    plot(frequency, abs(shiftedSpectrum) / sampleCount);
    title(plotTitle);
    xlabel('Frequency (Hz)');
    ylabel('Normalized magnitude');
    grid on;
end
