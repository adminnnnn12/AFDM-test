function [AFDM_demod_signal, H_DemodMatrix] = AFDM_demod(r, c1, c2)
    % 输入:
    %   r: 接收到的时域信号向量 (长度为 N，已去除 CPP)
    %   c1: 啁啾参数
    %   c2: 啁啾参数
    % 输出:
    %   y: 解调后的 DAFT 域符号向量
    
    N = length(r);
    r = r(:);
    
    L_c1 = diag(exp(-1j * 2 * pi * c1 * ((0:N-1).^2)));
    L_c2 = diag(exp(-1j * 2 * pi * c2 * ((0:N-1).^2)));
    DFT_matrix = zeros(N, N);
    for m = 0 : N-1
        for n = 0 : N-1
            DFT_matrix(m+1, n+1) = exp(-1j * 2 * pi * m * n / N) / sqrt(N);
        end
    end
    H_DemodMatrix = L_c2 * DFT_matrix * L_c1;

    AFDM_demod_signal = H_DemodMatrix * r;
end