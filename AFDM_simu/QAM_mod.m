function [modulated_signal] = QAM_mod(bit_stream, M)
    % 输入:
    %   bit_stream: 原始二进制比特序列 (行向量或列向量)
    %   M: 调制阶数
    % 输出:
    %   modulated_signal: 调制后的复数符号向量
    %   constellation: 所使用的星座图映射表

    n_bits = length(bit_stream);
    k = log2(M);
    if mod(n_bits, k) ~= 0
        error('比特流长度必须是 log2(M) 的整数倍。');
    end

    bit_reshape = reshape(bit_stream, k, []).';
    symbol_indices = bi2de(bit_reshape, 'left-msb');
    modulated_signal = qammod(symbol_indices, M, 'UnitAveragePower', true, 'PlotConstellation', false);
end