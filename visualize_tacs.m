function visualize_tacs(tacs,input,frames,roi_info,results_dir)

if(size(input,2)>1)
    u = max(tacs(:))/max(input(:,2));
    if(u>50)
        input(:,2) = 1000*input(:,2);
    elseif(u<0.02)
        input(:,2) = 0.001*input(:,2);
    end
else
    u = max(tacs(:))/max(input(:));
    if(u>50)
        input(:,2) = 1000*input(:);
    elseif(u<0.02)
        input(:,2) = 0.001*input(:);
    end
end

t = mean(frames,2);
d = sprintf('%s/tacs',results_dir);
if(~exist(d,'dir'))
    mkdir(d);
end
if(length(t)>1)
    N = size(tacs,1);
    if(length(input)~=length(t))
        p = spline(input(:,1),input(:,2));
        input = ppval(p,t);
    end
    
    for i = 1:N
        fig = figure('Visible','Off');
        plot(t,tacs(i,:),'ko-'); hold on; plot(t,input,'k--');
        xlabel('Time (min)'); ylabel('Radioactivity concentration');
        title(roi_info.labels{i});
        img_name = sprintf('%s/%s.png',d,roi_info.labels{i});
        print('-noui',img_name,'-dpng');
        close(fig);
    end
end

fname = sprintf('%s/tacs.mat',d);
save(fname,'tacs','input','frames','roi_info');

end