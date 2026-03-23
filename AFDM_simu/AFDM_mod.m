function [AFDM_symbol, H_ModMatrix] = AFDM_mod(X, c1, c2)
    % 输入:
    %   X: 输入调制符号
    %   c1: 啁啾参数
    %   c2：啁啾参数
    % 输出:
    %   AFDM_symbol: 调制后的AFDM符号向量

    sizeX = size(X);
    N = sizeX(1);
    
    L_c1 = diag(exp(-1j*2*pi*c1*((0:N-1).^2)));
    L_c2 = diag(exp(-1j*2*pi*c2*((0:N-1).^2)));
    DFT_matrix = zeros(N, N);
    for i = 0 : N-1
        for j = 0: N-1
            DFT_matrix(i+1,j+1) = exp(-1j*2*pi*i*j/N)/sqrt(N);
        end
    end
    
    A_Matrix = L_c2*DFT_matrix'*L_c1; 
    AFDM_symbol = A_Matrix'*X;
    H_ModMatrix = A_Matrix';
end