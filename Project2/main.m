%% Signals and Systems Course Project - Project 2
% Compare centre cancellation, bass rescue, and adaptive cancellation on
% every stereo WAV placed directly in the Project2 folder.
clear; clc; close all;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'functions'));
inputRoot = fullfile(projectRoot, 'data', 'local_audio');
outputRoot = fullfile(projectRoot, 'outputs');
if ~exist(outputRoot, 'dir')
    mkdir(outputRoot);
end

audioFiles = dir(fullfile(inputRoot, '*.wav'));
if isempty(audioFiles)
    error('No WAV files were found in %s. See Project2/data/README.md.', inputRoot);
end

for fileIndex = 1:length(audioFiles)
    inputPath = fullfile(audioFiles(fileIndex).folder, audioFiles(fileIndex).name);
    [inputAudio, Fs] = audioread(inputPath);
    if size(inputAudio, 2) ~= 2
        warning('Skipping %s because it is not stereo.', audioFiles(fileIndex).name);
        continue;
    end

    fprintf('Processing %s ...\n', audioFiles(fileIndex).name);
    [basic, bassRescue, adaptive, info] = myVoiceEliminator(inputAudio, Fs);

    % Use one common safety scale for all processed outputs. Separate peak
    % normalization would make loudness and waveform comparisons misleading.
    processedPeak = max(abs([basic; bassRescue; adaptive]));
    commonScale = min(1, 0.98 / max(processedPeak, eps));
    basic = commonScale * basic;
    bassRescue = commonScale * bassRescue;
    adaptive = commonScale * adaptive;

    [~, baseName] = fileparts(audioFiles(fileIndex).name);
    caseOutput = fullfile(outputRoot, baseName);
    if ~exist(caseOutput, 'dir')
        mkdir(caseOutput);
    end
    audiowrite(fullfile(caseOutput, 'basic_L_minus_R.wav'), basic, Fs);
    audiowrite(fullfile(caseOutput, 'legacy_bass_rescue.wav'), bassRescue, Fs);
    audiowrite(fullfile(caseOutput, 'adaptive_cancellation.wav'), adaptive, Fs);

    time = (0:length(inputAudio)-1)' / Fs;
    figureHandle = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [100, 100, 1000, 720]);
    tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    nexttile; plot(time, inputAudio(:, 1)); title('Original left channel');
    nexttile; plot(time, basic); title('Basic centre cancellation: L-R');
    nexttile; plot(time, bassRescue); title('Legacy bass-rescue baseline');
    nexttile; plot(time, adaptive); title('Adaptive frequency-dependent cancellation');
    axesList = findall(figureHandle, 'Type', 'axes');
    for axisIndex = 1:length(axesList)
        grid(axesList(axisIndex), 'on');
        xlabel(axesList(axisIndex), 'Time (s)');
        ylabel(axesList(axisIndex), 'Amplitude');
    end
    exportgraphics(figureHandle, fullfile(caseOutput, 'waveform_comparison.png'), ...
        'Resolution', 180);
    close(figureHandle);

    left = inputAudio(:, 1);
    right = inputAudio(:, 2);
    correlation = corrcoef(left, right);
    centre = 0.5 * (left + right);
    side = 0.5 * (left - right);
    midSideDb = 10 * log10((sum(centre.^2) + eps) / (sum(side.^2) + eps));
    metricsPath = fullfile(caseOutput, 'diagnostic_metrics.txt');
    fileId = fopen(metricsPath, 'w');
    fprintf(fileId, 'File: %s\n', audioFiles(fileIndex).name);
    fprintf(fileId, 'Sample rate: %d Hz\n', Fs);
    fprintf(fileId, 'Duration: %.3f s\n', length(inputAudio) / Fs);
    fprintf(fileId, 'L/R correlation: %.6f\n', correlation(1, 2));
    fprintf(fileId, 'Mid-to-side energy: %.3f dB\n', midSideDb);
    fprintf(fileId, 'Common output scale: %.6f\n', commonScale);
    fprintf(fileId, 'Legacy bass cutoff: %.1f Hz\n', info.bassCutoff);
    fclose(fileId);
end

disp('Project 2 processing complete. Run experiments/run_vocal_benchmark.m for objective validation.');
