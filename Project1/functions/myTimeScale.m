function [y_scaled, t_scaled] = myTimeScale(y, Fs, a)
    % y: 原信号
    % Fs: 原采样率
    % a: 尺度因子，例如 a=3 表示 f(3t)，a=1/3 表示 f(t/3)
    % y_scaled: 变换后的信号数据
    
    % 1. 获取原信号的时间轴

    N = length(y); %离散信号，所采总的点数
    t = (0 : N-1)' / Fs;  %对应点除以采样率显然是对应时间
    
    % 2. 计算新信号的时间轴范围

    % 尺度变换 f(at)：如果 a=3，新信号的时长是原来的 1/3；如果 a=1/3，时长是原来的 3 倍
    N_new = floor((N-1) / a) + 1; %0点默认筛选，剩下N-1个点只有落在新的采样点上才可以被筛选
    t_scaled = (0 : N_new-1)' / Fs; %实际新的时间轴
    
    % 3. 核心数学映射：f_new(t) = f_original(a * t)

    % 我们想知道新时间轴 t_scaled 上的点对应原信号的什么时间
    t_query = t_scaled * a;%映射到原时间轴，用于插值获取新的信号值(离散点变换后拟合也有不同)
    
    % 4. 使用一维线性插值获取数值，超出边界的部分补 0
    y_scaled = interp1(t, y, t_query, 'linear', 0);
end