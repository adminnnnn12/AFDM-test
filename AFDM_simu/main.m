clc; clear; close all;
%% System Parameter
delta_f = 15e3;
N_sub = 64;
Bandwidth = N_sub * delta_f;
fs = Bandwidth;
fc = 4e9;

%% Parameter
max_Delay = 16;                       % 最大时延 l_max (Ts归一化)
max_Doppler = 2 ;                     % 最大多普勒频偏(delta_f归一化)
lightspeed = 299792458;               % 光速
max_Range = max_Delay/fs*lightspeed;  % 最大时延对应的最远距离
max_Vel = max_Doppler*delta_f;        % 最大多普勒频偏对应的速度
ksi_nv = 4;                           
c1 = (2*(max_Doppler+ksi_nv)+1) / (2*N_sub);   % AFDM调制解调参数c1
c2 = 0.001 / (2*N_sub);               % AFDM调制解调参数c2
L_cp = 10;                            % CPP长度(Ts归一化)

%% Tx
bit_len = 102400;
bit_stream = randi([0 1], bit_len, 1);
tx_signals = QAM_mod(bit_stream, 16); 
[AFDM_symbol, H_ModMatrix] = AFDM_mod(tx_signals(1:N_sub), c1, c2);
AFDM_symbol_add_CPP = AFDM_add_CPP(AFDM_symbol, N_sub, L_cp, c1);

AFDM_TimeFreqLattice_Plot(N_sub, fs, c1);                  % 绘制时频资源图

%% LTV Channel
Path = 1;                                                  % 主径数
h = (randn(1, Path) + 1j*randn(1, Path)) / sqrt(2*Path);   % 复增益
l = [0, randi([1, L_cp-1], 1, Path-1)];                    % 时延（整数）（小于L_cp）
f_doppler = -max_Doppler + 2*max_Doppler*rand(1, Path);    % 多普勒(小于max_Doppler)
f_doppler_int = round(f_doppler);                          % 多普勒整数部分
f_doppler_fra = f_doppler - f_doppler_int;                 % 多普勒分数部分 (-0.5, 0.5]
loc_i = mod(2*N_sub*c1.*l + f_doppler_int, N_sub);
SNR = [50,50,50];
[r_signal, H_ChannelMatrix, H_ChannelMatrix_Path, noise] = AFDM_LTV_Channel(AFDM_symbol_add_CPP, N_sub, Path, h, l, f_doppler, delta_f, SNR, c1);

AFDM_Channel_Matrix_Plot(H_ChannelMatrix, "gray");    % 绘制信道矩阵热力图 type = "parula" / "gray"

%% Rx
r_deCPP = r_signal(L_cp+1 : end);
[AFDM_demod_signal, H_DemodMatrix] = AFDM_demod(r_deCPP, c1, c2);
H_eff = H_ModMatrix * H_ChannelMatrix * H_DemodMatrix;
AFDM_Channel_Matrix_Plot(H_eff, "gray")

%% 
%% 2. 定位总矩阵的最大值位置
% 2.1 计算矩阵的幅值（能量）
H_amp = abs(H_ChannelMatrix);
% 2.2 找到全局最大值的行/列索引（MATLAB索引从1开始，需+1）
[max_val, max_idx] = max(H_amp(:));  % 展开为一维找最大值
[max_row, max_col] = ind2sub(size(H_amp), max_idx);  % 转换为二维索引
fprintf('等效信道矩阵全局最大值：%.4f，位置：行%d，列%d\n', max_val, max_row, max_col);

%% 3. 验证：最大值位置是否匹配loc_i（需考虑1-based索引）
loc_i_1based = loc_i + 1;  % 转换为MATLAB的1-based索引
fprintf('各径loc_i（1-based）：%s\n', num2str(loc_i_1based));
% 检查最大值位置是否在loc_i_1based中
is_match = ismember([max_row, max_col], loc_i_1based);
fprintf('最大值行/列是否匹配loc_i：行=%d，列=%d\n', is_match(1), is_match(2));

%% 4. 逐径验证（看每径矩阵的最大值位置）
for i = 1:Path
    H_path_amp = abs(H_ChannelMatrix_Path(:,:,i));
    [max_val_i, max_idx_i] = max(H_path_amp(:));
    [max_row_i, max_col_i] = ind2sub(size(H_path_amp), max_idx_i);
    fprintf('第%d径矩阵最大值：%.4f，位置：行%d，列%d（对应loc_i=%d）\n',...
        i, max_val_i, max_row_i, max_col_i, loc_i(i));
end







 