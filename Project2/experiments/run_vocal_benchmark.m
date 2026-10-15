%% Controlled benchmark for the vocal-reduction algorithms
% The synthetic mixture has known vocal and accompaniment components, so
% attenuation and accompaniment distortion can be measured objectively.
clear; clc; close all;

experimentRoot = fileparts(mfilename('fullpath'));
projectRoot = fileparts(experimentRoot);
addpath(fullfile(projectRoot, 'functions'));
resultRoot = fullfile(experimentRoot, 'results');
if ~exist(resultRoot, 'dir')
    mkdir(resultRoot);
end

rng(7);
Fs = 16000;
duration = 8;
time = (0:round(duration * Fs)-1)' / Fs;

envelope = 0.45 + 0.35 * sin(2 * pi * 1.7 * time).^2;
vocal = envelope .* (0.52 * sin(2 * pi * 180 * time) ...
    + 0.24 * sin(2 * pi * 360 * time + 0.3) ...
    + 0.13 * sin(2 * pi * 540 * time + 0.8) ...
    + 0.08 * sin(2 * pi * 900 * time + 0.2));

noiseLeft = filter(1, [1, -0.92], randn(size(time)));
noiseRight = filter(1, [1, -0.89], randn(size(time)));
noiseLeft = noiseLeft / std(noiseLeft);
noiseRight = noiseRight / std(noiseRight);
sharedBass = 0.13 * sin(2 * pi * 75 * time);
musicLeft = sharedBass + 0.20 * sin(2 * pi * 247 * time + 0.1) ...
    + 0.12 * sin(2 * pi * 713 * time) + 0.025 * noiseLeft;
musicRight = sharedBass + 0.19 * sin(2 * pi * 294 * time + 0.6) ...
    + 0.11 * sin(2 * pi * 659 * time + 0.4) + 0.025 * noiseRight;
accompaniment = [musicLeft, musicRight];

scenarioNames = {'ideal_centre', 'gain_delay_mismatch'};
methodNames = {'basic_L_minus_R', 'legacy_bass_rescue', 'adaptive'};
rowCount = length(scenarioNames) * length(methodNames);
rows = cell(rowCount, 1);
rowIndex = 0;

for scenarioIndex = 1:length(scenarioNames)
    if scenarioIndex == 1
        vocalStereo = [vocal, vocal];
    else
        delaySamples = 2;
        delayedVocal = [zeros(delaySamples, 1); vocal(1:end-delaySamples)];
        vocalStereo = [vocal, 0.82 * delayedVocal];
    end
    unscaledMixture = accompaniment + vocalStereo;
    scale = 0.75 / max(abs(unscaledMixture), [], 'all');
    mixture = scale * unscaledMixture;
    scaledAccompaniment = scale * accompaniment;
    scaledVocal = scale * vocalStereo;

    [~, ~, ~, info] = myVoiceEliminator(mixture, Fs);
    model = info.adaptiveModel;

    [mixBasic, mixBass] = legacyOutputs(mixture, Fs);
    [vocalBasic, vocalBass] = legacyOutputs(scaledVocal, Fs);
    [musicBasic, musicBass] = legacyOutputs(scaledAccompaniment, Fs);
    mixAdaptive = applyAdaptiveCancellation(mixture, model);
    vocalAdaptive = applyAdaptiveCancellation(scaledVocal, model);
    musicAdaptive = applyAdaptiveCancellation(scaledAccompaniment, model);

    mixtureOutputs = {mixBasic, mixBass, mixAdaptive};
    vocalOutputs = {vocalBasic, vocalBass, vocalAdaptive};
    musicOutputs = {musicBasic, musicBass, musicAdaptive};
    referenceVocal = mean(scaledVocal, 2);
    referenceSide = scaledAccompaniment(:, 1) - scaledAccompaniment(:, 2);

    for methodIndex = 1:length(methodNames)
        rowIndex = rowIndex + 1;
        vocalOutput = vocalOutputs{methodIndex};
        musicOutput = musicOutputs{methodIndex};
        vocalAttenuationDb = max(-80, ...
            dbRatio(rmsValue(vocalOutput), rmsValue(referenceVocal)));
        outputSnrDb = 10 * log10((sum(musicOutput.^2) + eps) ...
            / (sum(vocalOutput.^2) + eps));
        alignmentScale = dot(referenceSide, musicOutput) ...
            / (dot(musicOutput, musicOutput) + eps);
        reconstructionError = referenceSide - alignmentScale * musicOutput;
        accompanimentSdrDb = min(80, 10 * log10((sum(referenceSide.^2) + eps) ...
            / (sum(reconstructionError.^2) + eps)));
        outputSnrDb = min(80, outputSnrDb);
        rows{rowIndex} = {scenarioNames{scenarioIndex}, methodNames{methodIndex}, ...
            vocalAttenuationDb, accompanimentSdrDb, outputSnrDb};
    end

    audiowrite(fullfile(resultRoot, [scenarioNames{scenarioIndex}, '_mixture.wav']), ...
        mixture, Fs);
    for methodIndex = 1:length(methodNames)
        output = mixtureOutputs{methodIndex};
        output = 0.95 * output / max(max(abs(output)), eps);
        audiowrite(fullfile(resultRoot, [scenarioNames{scenarioIndex}, '_', ...
            methodNames{methodIndex}, '.wav']), output, Fs);
    end
end

csvPath = fullfile(resultRoot, 'benchmark_metrics.csv');
fileId = fopen(csvPath, 'w');
fprintf(fileId, 'scenario,method,vocal_attenuation_db,accompaniment_sdr_db,output_snr_db\n');
for resultIndex = 1:length(rows)
    row = rows{resultIndex};
    fprintf(fileId, '%s,%s,%.4f,%.4f,%.4f\n', row{1}, row{2}, row{3}, row{4}, row{5});
end
fclose(fileId);

attenuation = zeros(length(scenarioNames), length(methodNames));
distortion = zeros(length(scenarioNames), length(methodNames));
outputSnr = zeros(length(scenarioNames), length(methodNames));
for resultIndex = 1:length(rows)
    scenarioIndex = ceil(resultIndex / length(methodNames));
    methodIndex = mod(resultIndex - 1, length(methodNames)) + 1;
    attenuation(scenarioIndex, methodIndex) = rows{resultIndex}{3};
    distortion(scenarioIndex, methodIndex) = rows{resultIndex}{4};
    outputSnr(scenarioIndex, methodIndex) = rows{resultIndex}{5};
end

figureHandle = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 420]);
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; bar(attenuation); title('Vocal leakage attenuation'); ylabel('dB (lower is better)');
nexttile; bar(distortion); title('Accompaniment SDR'); ylabel('dB (higher is better)');
nexttile; bar(outputSnr); title('Output accompaniment-to-vocal ratio'); ylabel('dB (higher is better)');
axisHandles = findall(figureHandle, 'Type', 'axes');
for axisIndex = 1:length(axisHandles)
    set(axisHandles(axisIndex), 'XTick', 1:length(scenarioNames), ...
        'XTickLabel', {'ideal centre', 'gain + delay mismatch'});
    grid(axisHandles(axisIndex), 'on');
end
legend(methodNames, 'Interpreter', 'none', 'Location', 'southoutside');
exportgraphics(figureHandle, fullfile(resultRoot, 'benchmark_summary.png'), 'Resolution', 200);
close(figureHandle);

fprintf('Benchmark complete. Results: %s\n', csvPath);

function [basic, bassRescue] = legacyOutputs(x, Fs)
    basic = x(:, 1) - x(:, 2);
    centre = 0.5 * (x(:, 1) + x(:, 2));
    bassRescue = basic + 0.30 * myIdealLPF(fft(centre), Fs, 160);
end

function value = rmsValue(x)
    value = sqrt(mean(x.^2));
end

function value = dbRatio(numerator, denominator)
    value = 20 * log10((numerator + eps) / (denominator + eps));
end
