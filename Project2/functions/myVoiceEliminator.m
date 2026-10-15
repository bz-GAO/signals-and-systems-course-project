function [y_basic, y_advanced] = myVoiceEliminator(y, Fs)
    % 检查是否为双声道
    if size(y, 2) < 2
        error('必须使用双声道(Stereo)音频！');
    end
    
    % 分离左右声道
    L = y(:, 1);
    R = y(:, 2);
    
    % --- 1. 基础版 Voice Eliminator (相减法) ---
    % 原理：消除位于中央相位的同频信号，若人声在声道中完全一致，理论可以完全去除
    y_basic = L - R;
    
    % --- 2. 进阶版 Voice Eliminator (低频补偿法) ---
    % 提取原曲中心声道的低频成分，防止完全消除
    CenterChannel = (L + R) / 2; 
    fc = 200; % 低通滤波器截止频率为 200 Hz
    
    % 复用 Project 1 中的理想低通滤波器提取低音
    % 人声多为高音，所以备份低音效益高
    Bass = myIdealLPF(fft(CenterChannel), Fs, fc);
    
    % 将低音叠加回消除人声后的信号中
    y_advanced = y_basic + Bass;
end