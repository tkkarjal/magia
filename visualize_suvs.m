function visualize_suvs(suvs,frames,roi_info,results_dir)

d = sprintf('%s/suvs',results_dir);
if(~exist(d,'dir'))
    mkdir(d);
end

t = mean(frames,2);
if(length(t)>1)
    N = size(suvs,1);
    for i = 1:N
        fig = figure('Visible','Off');
        plot(t,suvs(i,:),'ko-');
        xlabel('Time (min)'); ylabel('Standardized uptake value');
        title(roi_labels{i});
        img_name = sprintf('%s/%s.png',d,roi_info.labels{i});
        print('-noui',img_name,'-dpng');
        close(fig);
    end
end

fname = sprintf('%s/suvs.mat',d);
save(fname,'suvs','frames','roi_info');

end
