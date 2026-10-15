function [y_basic, y_bass_rescue, y_adaptive, info] = myVoiceEliminator(x, Fs)
%MYVOICEELIMINATOR Compare three classical centre-cancellation methods.
%   BASIC is ordinary L-R cancellation. BASS_RESCUE adds back a restrained
%   low-frequency centre component and is retained as a legacy baseline.
%   ADAPTIVE estimates a frequency-dependent L/R transfer function.

    if size(x, 2) ~= 2
        error('Input must be a two-channel stereo signal.');
    end

    left = x(:, 1);
    right = x(:, 2);
    y_basic = left - right;

    centre = 0.5 * (left + right);
    bassCutoff = 160;
    bassMix = 0.30;
    bass = myIdealLPF(fft(centre), Fs, bassCutoff);
    y_bass_rescue = y_basic + bassMix * bass;

    [y_adaptive, adaptiveModel] = myAdaptiveVoiceEliminator(x, Fs);

    info = struct();
    info.bassCutoff = bassCutoff;
    info.bassMix = bassMix;
    info.adaptiveModel = adaptiveModel;
end
