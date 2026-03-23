function [r_full, H_eq, H_ChannelMatrix_path, noise] = AFDM_LTV_Channel(s, N, P, h, l, f, delta_f, SNR, c1)
    % 输入参数:
    % s: 发送的时域信号 (包含 CPP)，长度 = N + L_cp
    % N: 子载波数量（有效数据段维度，论文核心）
    % P: 路径数
    % h: 复增益向量 (1 x P)
    % l: 整数时延向量 (1 x P)（< L_cp）
    % f: 归一化多普勒频移向量 (1 x P)
    % delta_f: 子载波间隔(Hz)
    % SNR：信噪比 (1 x P)
    % c1：AFDM参数
    % 输出参数:
    % r_full: 含CPP接收有效信号 (N×1)
    % H_eq: 等效信道矩阵 (N×N)
    % H_ChannelMatrix_path: 各路径信道矩阵 (N×N×P), 分离hi增益
    % noise: 去CP后的噪声 (N×1)

    % ========== 1. 基础参数提取 ==========
    L_cp = length(s) - N;  
    s_eff = s(L_cp+1 : end);  
    noise_full = zeros(size(s)) + 1i*zeros(size(s));  
    n_eff = (0:N-1)';  

    % ========== 2. 实际信道传输（含CP） ==========
    r_full = zeros(length(s), 1) + 1i*zeros(length(s), 1);  % 含CP接收信号
    for i = 1:P
        s_delayed = circshift(s, l(i)); 
        doppler_shift_full = zeros(length(s), 1) + 1i*zeros(length(s), 1);
        doppler_shift_full(L_cp+1:end) = exp(-1j * 2 * pi * f(i)*delta_f * n_eff);  
        path_signal_pure = h(i) * doppler_shift_full .* s_delayed;
        path_power = mean(abs(path_signal_pure(L_cp+1:end)).^2); 
        N0_path = path_power / (10^(SNR(i)/10));
        noise_path = sqrt(N0_path/2) * (randn(size(s)) + 1j*randn(size(s)));
        r_full = r_full + path_signal_pure + noise_path;
        noise_full = noise_full + noise_path;
    end

    % ========== 3. （去CP） ==========
    r = r_full(L_cp+1 : end);          % 去CP后接收有效信号 (N×1)
    noise = noise_full(L_cp+1 : end);  % 去CP后噪声 (N×1)

    % ========== 4. 构造 N×N 信道矩阵 ==========
    H_ChannelMatrix_path = zeros(N, N, P) + 1i*zeros(N, N, P); 
    I_N = eye(N); 

    for i = 1:P
        P_l = circshift(I_N, [0, -l(i)]);
        Delta_f = diag(exp(-1j * 2 * pi * f(i)*delta_f * n_eff));
        Gamma_CPP = eye(N);  
        for n = 0 : l(i)-1  % 仅补偿n < l_i的位置
            Gamma_CPP(n+1, n+1) = exp(-1j * 2 * pi * c1 * (N^2 - 2 * N * (l(i) - n)));
        end
        H_ChannelMatrix_path(:,:,i) = h(i) * Gamma_CPP * Delta_f * P_l;
    end
    H_eq = sum(H_ChannelMatrix_path, 3);

    % ========== 5. 验证等效信道矩阵 ==========
    r_theory = H_eq * s_eff + noise;           % 理论值：H_eq × 发送有效信号 + 噪声
    error_eq = norm(r - r_theory) / norm(r);   % 误差量
    if error_eq > 1e-8
        warning("论文等效矩阵验证误差：%.4e（维度已严格N×N）", error_eq);
    end

end