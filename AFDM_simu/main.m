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
l = randi([0, L_cp-1], 1, Path);                           % 时延（整数）（小于L_cp） 
f_doppler = -max_Doppler + 2*max_Doppler*rand(1, Path);    % 多普勒(小于max_Doppler)
f_doppler_int = round(f_doppler);                          % 多普勒整数部分
f_doppler_fra = f_doppler - f_doppler_int;                 % 多普勒分数部分 (-0.5, 0.5]
loc_i = mod(2*N_sub*c1.*l + f_doppler_int, N_sub)-1;
SNR = [50,50,50];
[r_signal, H_ChannelMatrix, H_ChannelMatrix_Path, noise] = AFDM_LTV_Channel(AFDM_symbol_add_CPP, N_sub, Path, h, l, f_doppler, delta_f, SNR, c1, fs);

AFDM_Channel_Matrix_Plot(H_ChannelMatrix, "gray");    % 绘制信道矩阵热力图 type = "parula" / "gray"

%% Rx
r_deCPP = r_signal(L_cp+1 : end);
[AFDM_demod_signal, H_DemodMatrix] = AFDM_demod(r_deCPP, c1, c2);
H_eff = H_DemodMatrix * H_ChannelMatrix * H_ModMatrix;
AFDM_Channel_Matrix_Plot(H_eff, "gray")








 