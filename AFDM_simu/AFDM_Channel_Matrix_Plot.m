function AFDM_Channel_Matrix_Plot(H_matrix, type)
    plot_matrix = H_matrix; 
  
    % 论文级绘图设置（高清、无白边、符合期刊格式）
    figure('Color','white','Position',[100,100,800,600],'PaperPositionMode','auto');
    ax = gca;
    % 绘制矩阵热力图（幅度/相位二选一，论文常用幅度）
    imagesc(ax, abs(plot_matrix)); % 幅度可视化（相位用angle(plot_matrix)）
    % 配色：论文常用jet/parula/hsv（相位用hsv，幅度用parula）
    if type == "parula"
        colormap(ax, parula); 
    elseif type == "gray"
        colormap(ax, flipud(gray)); 
    end
    colorbar(ax, 'Location','eastoutside'); % 色标放在右侧
    % 标题/轴标签（适配论文格式）
    title('Fig2: LTV Channel Matrix of AFDM System','FontSize',14,'FontWeight','bold','FontName','Times New Roman');
    xlabel('Frequency Dimension (Subcarrier Index)','FontSize',12,'FontName','Times New Roman');
    ylabel('Time Dimension (Sample Index, including CP)','FontSize',12,'FontName','Times New Roman');
    % 论文格式优化
    ax.LineWidth = 1;          % 边框宽度
    ax.FontSize = 10;          % 刻度字体大小
    ax.FontName = 'Times New Roman'; % 期刊常用字体
    ax.TickDir = 'in';         % 刻度向内（论文规范）
    ax.GridAlpha = 0.3;        % 网格透明度
    grid(ax, 'on');            % 显示网格
    axis(ax, 'square');        % 正方形矩阵（美观）




end