function roi_bars(T,modeling_options,results_dir)

idx = regexp(results_dir,'/');
subject = results_dir(idx(end-1)+1:idx(end)-1);

switch lower(modeling_options.model)
    case 'srtm'
        fig = figure('Visible','Off'); bar(table2array(T(:,3))); box off;
        xlabel('Region of interest'); ylabel('BPnd');
        set(gca,'xtick',1:length(T.Properties.RowNames));
        set(gca,'xticklabel',T.Properties.RowNames);
        xtickangle(90);
        img_name = sprintf('%s/roi_bars.png',results_dir);
        print('-noui',img_name,'-dpng');
        add_to_qc_pic(subject,fig);
        close(fig);
    case {'patlak','patlak_ref'}
        fig = figure('Visible','Off'); bar(table2array(T(:,1))); box off;
        xlabel('Region of interest'); ylabel('Ki');
        set(gca,'xtick',1:length(T.Properties.RowNames));
        set(gca,'xticklabel',T.Properties.RowNames);
        xtickangle(90);
        img_name = sprintf('%s/roi_bars.png',results_dir);
        print('-noui',img_name,'-dpng');
        add_to_qc_pic(subject,fig);
        close(fig);
    case 'fur'
        fig = figure('Visible','Off'); bar(table2array(T(:,1))); box off;
        xlabel('Region of interest'); ylabel('FUR');
        set(gca,'xtick',1:length(T.Properties.RowNames));
        set(gca,'xticklabel',T.Properties.RowNames);
        xtickangle(90);
        img_name = sprintf('%s/roi_bars.png',results_dir);
        print('-noui',img_name,'-dpng');
        add_to_qc_pic(subject,fig);
        close(fig);
    case 'suvr'
        fig = figure('Visible','Off'); bar(table2array(T(:,1))); box off;
        xlabel('Region of interest'); ylabel('SUVR');
        set(gca,'xtick',1:length(T.Properties.RowNames));
        set(gca,'xticklabel',T.Properties.RowNames);
        xtickangle(90);
        img_name = sprintf('%s/roi_bars.png',results_dir);
        print('-noui',img_name,'-dpng');
        add_to_qc_pic(subject,fig);
        close(fig);
    case 'logan'
        fig = figure('Visible','Off'); bar(table2array(T(:,1))); box off;
        xlabel('Region of interest'); ylabel('V_T');
        set(gca,'xtick',1:length(T.Properties.RowNames));
        set(gca,'xticklabel',T.Properties.RowNames);
        xtickangle(90);
        img_name = sprintf('%s/roi_bars.png',results_dir);
        print('-noui',img_name,'-dpng');
        add_to_qc_pic(subject,fig);
        close(fig);
    otherwise
        warning('roi_bars has not been implemented for %s.',modeling_options.model);
end

end