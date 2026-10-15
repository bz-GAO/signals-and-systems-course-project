function y_filtered = myIdealLPF(Y, Fs, fc)
    % Y: 未经 shift 的原始 FFT 数据
    % Fs: 采样率
    % fc: 截止频率 (Hz)
    
    N = length(Y);
    % 1. 先把频谱 shift 到对称，方便去掉高频
    Y_shifted = fftshift(Y);
    f_axis = linspace(-Fs/2, Fs/2, N)';
    
    % 2. 构造理想低通滤波器（频率绝对值 <= fc 的地方为 1，其余为 0）
    H = abs(f_axis) <= fc; %逻辑表达式，形成方波幅值为1，所以后续不用再处理
    
    % 3. 频域相乘 (滤波操作)
    Y_filtered_shifted = Y_shifted .* H;
    
    % 4. 把频谱 shift 回去，并做 IFFT，最后取实部消除微小的计算误差
    y_filtered = real(ifft(ifftshift(Y_filtered_shifted)));
end