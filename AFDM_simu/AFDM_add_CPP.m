function signal_add_CPP = AFDM_add_CPP(signal, N, L_cp, c1)
    % 输入参数:
    % signal: 未加前缀的时域信号 (1 x N)
    % N: 子载波数量 
    % L_cp: 前缀长度 (需 >= 最大时延样本数) 
    % c1: AFDM 变换参数 
    
    % 1. 提取信号末尾的 L_cp 个采样点 
    suffix = signal(end - L_cp + 1 : end);
    
    % 2. 计算相位旋转因子 (n 从 -L_cp 到 -1)
    n_prefix = (-L_cp : -1)'; % 转置为列向量
    % 严格执行论文公式 (21) [cite: 190]
    phi = exp(-1j * 2 * pi * c1 * (N^2 + 2 * N * n_prefix));
    
    % 3. 应用相位旋转得到 CPP
    cpp = suffix .* phi;
    
    % 4. 垂直拼接得到 (N + L_cp) x 1 的传输符号
    signal_add_CPP = [cpp; signal];
end