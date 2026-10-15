%% Signal and Systems Course Project - Project 2: Voice Eliminator
clear; clc; close all;

% 载入函数路径和输出文件夹
addpath('functions');
%outputDir = '夜空はなんでも知ってるの';
outputDir = 'rollinginthedeep'
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% 1. 读取音频信号
% filename = '夜空はなんでも知ってるの.wav'; 
filename = 'rollinginthedeep.wav'
[y, Fs] = audioread(filename);

% 生成时间轴
N = length(y);
t = (0 : N-1)' / Fs;

%% 2. 运行 Voice Eliminator 算法
disp('正在消除人声，请稍候...');
[y_basic, y_advanced] = myVoiceEliminator(y, Fs);

% 归一化防爆音处理 (让最大音量不超过 1.0)
y_basic = y_basic / max(abs(y_basic));
y_advanced = y_advanced / max(abs(y_advanced));

%% 3. 结果保存与对比
audiowrite(fullfile(outputDir, '1_Original_Song.wav'), y, Fs);
audiowrite(fullfile(outputDir, '2_Basic_Eliminator.wav'), y_basic, Fs);
audiowrite(fullfile(outputDir, '3_Advanced_Eliminator.wav'), y_advanced, Fs);

%% 4. 绘制对比图象 
figure('Name', 'Voice Eliminator Performance Analysis', 'Position', [100, 100, 800, 600]);

subplot(3, 1, 1);
plot(t, y(:,1)); % 画左声道作为原信号参考
title('Original Song (Left Channel)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(3, 1, 2);
plot(t, y_basic);
title('Basic Voice Elimination (L - R)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(3, 1, 3);
plot(t, y_advanced);
title('Advanced Elimination with Bass Rescue');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

linkaxes(findall(gcf, 'Type', 'axes'), 'xy');
disp('人声消除完成，请去 outputs 文件夹试听效果。');