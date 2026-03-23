function [r_full, H_eq, H_ChannelMatrix_path, noise] = AFDM_LTV_Channel(s, N, P, h, l, f, delta_f, SNR, c1, fs)
    % ========== 1. 基础参数提取 ==========
    L_cp = length(s) - N;  
    s_eff = s(L_cp+1 : end);  
    n_eff = (0:N-1)';  

    % ========== 2. 实际信道传输 (模拟物理信道) ==========
    % 建议先合成纯净信号，最后统一加噪
    r_pure_full = zeros(length(s), 1); 
    for i = 1:P
        % 模拟线性延迟 (非循环移位): 延迟l(i)位，前面补0
        s_delayed = [zeros(l(i), 1); s(1:end-l(i))]; 
        
        % 统一多普勒计算：f(i)为归一化多普勒 (k_i)
        % 相位 = 2*pi * (f_Hz * t) = 2*pi * (f(i)*delta_f) * (n/fs)
        n_full = (0:length(s)-1)';
        doppler_shift = exp(-1j * 2 * pi * (f(i) * delta_f) * n_full / fs);
        
        r_pure_full = r_pure_full + h(i) * doppler_shift .* s_delayed;
    end

    % 统一添加加性高斯白噪声
    sig_pwr = mean(abs(r_pure_full(L_cp+1:end)).^2);
    noise_pwr = sig_pwr / (10^(SNR(1)/10)); % 简化为使用第一个SNR
    noise_full = sqrt(noise_pwr/2) * (randn(size(s)) + 1j*randn(size(s)));
    r_full = r_pure_full + noise_full;

    % 去前缀
    r = r_full(L_cp+1 : end);
    noise = noise_full(L_cp+1 : end);

    % ========== 3. 构造理论 N×N 信道矩阵 (基于 CPP 理论) ==========
    H_ChannelMatrix_path = zeros(N, N, P); 
    I_N = eye(N); 
    for i = 1:P
        % 延迟算子
        P_l = circshift(I_N, [l(i), 0]); % 注意移位方向与你之前 P_l = circshift(I_N, [0, -l(i)]) 的结果一致性
        % 归一化多普勒算子
        Delta_f = diag(exp(-1j * 2 * pi * (f(i) * delta_f) * (n_eff + L_cp) / fs)); 
        % CPP 补偿矩阵
        Gamma_CPP = eye(N);  
        for n = 0 : l(i)-1 
            Gamma_CPP(n+1, n+1) = exp(-1j * 2 * pi * c1 * (N^2 - 2 * N * (l(i) - n)));
        end
        H_ChannelMatrix_path(:,:,i) = h(i) * Delta_f * Gamma_CPP * P_l;
    end
    H_eq = sum(H_ChannelMatrix_path, 3);

    % ========== 4. 验证 ==========
    r_theory = H_eq * s_eff; 
    error_eq = norm(r - noise - r_theory) / norm(r - noise); % 验证纯信号部分
    if error_eq > 1e-8
        fprintf("误差较大: %.4e. 检查 Delta_f 的起始相位 (n_eff + L_cp) 是否匹配.\n", error_eq);
    end
end