function AFDM_TimeFreqLattice_Plot(N_sub, fs, c1)
% PLOTAFDMTIMEFREQLATTICE 绘制AFDM全子载波时频资源格型图
% 输入参数：
%   N_sub - 子载波数量，必须为正整数
%   fs    - 采样率（Hz）
%   c1    - AFDM倾斜系数
% 输出：
%   弹出AFDM时频资源图窗口

%% 核心绘图逻辑
% 1. 生成时间/子载波索引
n = 0 : N_sub-1;                   % 子载波索引
t = n / fs;                        % 时间轴（单位：s）
colors = jet(N_sub);               % 子载波配色（每个子载波对应一种颜色）

% 2. 创建图形窗口
figure('Color', 'w', 'Name', 'AFDM Time-Frequency Lattice');
hold on; grid on;
box on; % 增加边框，更符合论文格式

% 3. 遍历每个子载波绘制时频轨迹
for m = 0 : N_sub-1
    % 计算第m个子载波的瞬时频率
    inst_freq = ( c1*(2*n-1) + (m/N_sub) ) * fs;  
    % 处理频率折叠（Modulo Bandwidth，避免频率超出采样率范围）
    inst_freq_mod = mod(inst_freq, fs);                    
    
    % 检测频率跳变点（避免折线跨频段显示）
    diff_f = diff(inst_freq_mod);
    jump_idx = find(abs(diff_f) > fs/2); % 跳变阈值：fs/2
    curr_start = 1;
    
    % 分段绘制（避免跳变点导致的折线错误）
    for j = 1:length(jump_idx)
        plot(t(curr_start:jump_idx(j)) * 1e6, ...  % 时间转换为μs
             inst_freq_mod(curr_start:jump_idx(j)) / 1e3, ... % 频率转换为kHz
             'Color', colors(m+1,:), 'LineWidth', 1);
        curr_start = jump_idx(j) + 1;
    end
    % 绘制最后一段
    plot(t(curr_start:end) * 1e6, ...
         inst_freq_mod(curr_start:end) / 1e3, ...
         'Color', colors(m+1,:), 'LineWidth', 1);
end

%% 图形修饰（论文级格式）
% 坐标轴标签
xlabel('时间 Time (\mu s)','FontSize',12,'FontName','Times New Roman');
ylabel('频率 Frequency (kHz)','FontSize',12,'FontName','Times New Roman');
% 标题（显示关键参数）
title(['AFDM 全子载波映射 (N=' num2str(N_sub) ', c_1=', num2str(c1, '%.4f'), ')'], ...
      'FontSize',14,'FontWeight','bold','FontName','Times New Roman');
% 坐标轴范围
set(gca, 'XLim', [0, (N_sub/fs)*1e6], ...  % 时间范围：0 ~ 符号时长(μs)
         'YLim', [0, fs/1e3], ...           % 频率范围：0 ~ 采样率(kHz)
         'FontSize',10,'FontName','Times New Roman', ...
         'TickDir','in'); % 刻度向内，符合论文规范
% 色标（关联子载波索引）
colormap jet;
h_cb = colorbar;
ylabel(h_cb, '子载波索引 Subcarrier Index','FontSize',10,'FontName','Times New Roman');

% 保持图形窗口激活
hold off;
end