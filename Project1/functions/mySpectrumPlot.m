function [Y, f_axis] = mySpectrumPlot(y, Fs, fig_title, subplot_pos)
    % 计算 FFT 并绘制频谱幅度图
    N = length(y);
    Y = fft(y); % 傅里叶变换函数
    
    % 将零频点移到频谱中心
    Y_shifted = fftshift(Y);
    
    % 构造对称的频率轴
    f_axis = linspace(-Fs/2, Fs/2, N);
    
    % 绘制幅度谱
    subplot(subplot_pos(1), subplot_pos(2), subplot_pos(3));
    plot(f_axis, abs(Y_shifted));
    title(fig_title);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
end