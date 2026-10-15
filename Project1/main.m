%% Signals and Systems Course Project - Project 1
clear; clc; close all;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'functions'));
outputDir = fullfile(projectRoot, 'outputs');
figureDir = fullfile(projectRoot, 'results');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
if ~exist(figureDir, 'dir'); mkdir(figureDir); end

[rawAudio, Fs] = audioread(fullfile(projectRoot, 'audio1.wav'));
signal = rawAudio(:, 1);
sampleCount = length(signal);
time = (0:sampleCount-1)' / Fs;

%% Time-domain transformations
reversedSignal = flipud(signal);
[compressedSignal, compressedTime] = myTimeScale(signal, Fs, 3);
[expandedSignal, expandedTime] = myTimeScale(signal, Fs, 1/3);

timeFigure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 900, 760]);
tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; plot(time, signal); title('Original signal f(t)');
nexttile; plot(time, reversedSignal); title('Time reversal f(-t)');
nexttile; plot(compressedTime, compressedSignal); title('Time compression f(3t)');
nexttile; plot(expandedTime, expandedSignal); title('Time expansion f(t/3)');
axesList = findall(timeFigure, 'Type', 'axes');
for axisIndex = 1:length(axesList)
    xlabel(axesList(axisIndex), 'Time (s)');
    ylabel(axesList(axisIndex), 'Amplitude');
    grid(axesList(axisIndex), 'on');
end
exportgraphics(timeFigure, fullfile(figureDir, 'time_transformations.png'), 'Resolution', 180);
close(timeFigure);

audiowrite(fullfile(outputDir, 'f_minus_t.wav'), reversedSignal, Fs);
audiowrite(fullfile(outputDir, 'f_3t.wav'), compressedSignal, Fs);
audiowrite(fullfile(outputDir, 'f_t_over_3.wav'), expandedSignal, Fs);

%% Fourier spectra
spectrumFigure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 900, 650]);
[originalSpectrum, ~] = mySpectrumPlot(signal, Fs, 'Spectrum of f(t)', [3, 1, 1]);
mySpectrumPlot(compressedSignal, Fs, 'Spectrum of f(3t)', [3, 1, 2]);
mySpectrumPlot(expandedSignal, Fs, 'Spectrum of f(t/3)', [3, 1, 3]);
exportgraphics(spectrumFigure, fullfile(figureDir, 'spectra.png'), 'Resolution', 180);
close(spectrumFigure);

%% Magnitude-only and phase-only reconstruction
magnitudeOnly = real(ifft(abs(originalSpectrum)));
phaseOnly = real(ifft(exp(1j * angle(originalSpectrum))));
reconstructionFigure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 900, 650]);
tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; plot(time, signal); title('Original signal'); grid on;
nexttile; plot(time, magnitudeOnly); title('Magnitude-only reconstruction'); grid on;
nexttile; plot(time, phaseOnly); title('Phase-only reconstruction'); grid on;
exportgraphics(reconstructionFigure, fullfile(figureDir, 'magnitude_phase_reconstruction.png'), 'Resolution', 180);
close(reconstructionFigure);

audiowrite(fullfile(outputDir, 'magnitude_only.wav'), normalizeForAudio(magnitudeOnly), Fs);
audiowrite(fullfile(outputDir, 'phase_only.wav'), normalizeForAudio(phaseOnly), Fs);

%% Ideal low-pass filtering
cutoff = 1000;
filteredSignal = myIdealLPF(originalSpectrum, Fs, cutoff);
filterFigure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 900, 500]);
tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; plot(time, signal); title('Original signal'); grid on;
nexttile; plot(time, filteredSignal); title(sprintf('Ideal low-pass output, f_c = %d Hz', cutoff)); grid on;
exportgraphics(filterFigure, fullfile(figureDir, 'ideal_low_pass.png'), 'Resolution', 180);
close(filterFigure);
audiowrite(fullfile(outputDir, 'filtered_1000Hz.wav'), normalizeForAudio(filteredSignal), Fs);

disp('Project 1 processing complete.');

function output = normalizeForAudio(input)
    peak = max(abs(input));
    output = 0.98 * input / max(peak, eps);
end
