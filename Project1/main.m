%% Signal and Systems Course Project - Project 1
clear; clc; close all;

% 将自定义函数文件夹加入路径
addpath('functions');

% 确保输出文件夹存在
outputDir = 'outputs';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% 1) 读取信号 f(t) 并展示波形
filename = 'audio1.wav';  
[y_raw, Fs] = audioread(filename);

% 提取单声道
f_t = y_raw(:, 1); 
N = length(f_t);
t = (0 : N-1)' / Fs;

figure('Name', 'Requirement 1 & 2: Time Domain Waveforms', 'Position', [100, 100, 800, 800]);

subplot(4,1,1);
plot(t, f_t); 
title('Original Signal f(t)'); 
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

%% 2) 生成尺度变换信号并画图
% f(-t) 反转
f_minus_t = flipud(f_t);%时间反转
subplot(4,1,2);
plot(t, f_minus_t); 
title('Time Reversal f(-t)'); 
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% f(3t) 压缩
[f_3t, t_3t] = myTimeScale(f_t, Fs, 3);
subplot(4,1,3);
plot(t_3t, f_3t); 
title('Time Compression f(3t)'); 
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% f(t/3) 扩展 (内部变量仍叫 t3/f_t3，但标题显示为 t/3)
[f_t3, t_t3] = myTimeScale(f_t, Fs, 1/3);
subplot(4,1,4);
plot(t_t3, f_t3); 
title('Time Expansion f(t/3)'); % 这里改成了可视化的 t/3
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

linkaxes(findall(gcf, 'Type', 'axes'), 'x');%同步部分坐标轴缩放

% 导出音频 
% audiowrite(fullfile(outputDir, 'f_minus_t.wav'), f_minus_t, Fs);
% audiowrite(fullfile(outputDir, 'f_3t.wav'), f_3t, Fs);
% audiowrite(fullfile(outputDir, 'f_t_over_3.wav'), f_t3, Fs); % 文件名用 over 表示

%% 3) 计算傅里叶变换并对比频谱
figure('Name', 'Requirement 3: Spectra Comparison', 'Position', [150, 150, 800, 600]);
[Y_orig, ~] = mySpectrumPlot(f_t, Fs, 'Spectrum of f(t)', [3,1,1]);
[Y_3t, ~]   = mySpectrumPlot(f_3t, Fs, 'Spectrum of f(3t)', [3,1,2]);
[Y_t3, ~]   = mySpectrumPlot(f_t3, Fs, 'Spectrum of f(t/3)', [3,1,3]); 

%% 4) 幅度谱与相位谱的独立逆傅里叶变换
% 只用幅度谱重建 (相位设为0)
%ifft为快速傅里叶变换反变换
y_mag_only = real(ifft(abs(Y_orig)));%real是为了消除机器误差

% 只用相位谱重建 (幅度设为1)
y_phase_only = real(ifft(exp(1j * angle(Y_orig))));

figure('Name', 'Requirement 4: Magnitude vs Phase Reconstruction');
% 统一 Y 轴刻度，让对比更明显
y_max = max(abs(f_t));

subplot(3,1,1); plot(t, f_t); ylim([-y_max y_max]);
title('Original Signal f(t)'); grid on;

subplot(3,1,2); plot(t, y_mag_only); ylim([-y_max y_max]);
title('Reconstructed from Magnitude Only |F(j\omega)|'); grid on;

subplot(3,1,3); plot(t, y_phase_only); ylim([-y_max y_max]);
title('Reconstructed from Phase Only e^{j\angle F(j\omega)}'); grid on;

% 导出音频
% audiowrite(fullfile(outputDir, 'mag_only.wav'), y_mag_only / max(abs(y_mag_only)), Fs);
% audiowrite(fullfile(outputDir, 'phase_only.wav'), y_phase_only / max(abs(y_phase_only)), Fs);

%% 5) 频域理想低通滤波
fc = 1000; 
y_lpf = myIdealLPF(Y_orig, Fs, fc);

figure('Name', 'Requirement 5: Low-Pass Filtering');
subplot(2,1,1); plot(t, f_t); 
title('Original Signal f(t)'); grid on;

subplot(2,1,2); plot(t, y_lpf); 
title(['Ideal Low-Pass Filtered (fc = ', num2str(fc), ' Hz)']); grid on;

% audiowrite(fullfile(outputDir, 'filtered_1000Hz.wav'), y_lpf, Fs);

disp('Project 1 计算完成');
disp('处理后的音频已存入 outputs 文件夹');