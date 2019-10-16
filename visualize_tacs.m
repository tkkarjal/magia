function visualize_tacs(tacs,input,frames,roi_labels,results_dir)

t = mean(frames,2);
d = sprintf('%s/tacs',results_dir);
if(~exist(d,'dir'))
    mkdir(d);
end
if(length(t)>1)
    N = size(tacs,1);
    if(length(input)~=length(t))
        input = pchip(input(:,1),input(:,2),t);
    end
    
    for i = 1:N
        fig = figure('Visible','Off');
        plot(t,tacs(i,:),'ko-'); hold on; plot(t,input,'k--');
        xlabel('Time (min)'); ylabel('Radioactivity concentration');
        title(roi_labels{i});
        img_name = sprintf('%s/%s.png',d,roi_labels{i});
        print('-noui',img_name,'-dpng');
        close(fig);
    end
end

fname = sprintf('%s/tacs.mat',d);
save(fname,'tacs','input','frames','roi_info');

end