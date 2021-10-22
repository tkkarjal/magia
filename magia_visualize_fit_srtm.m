function magia_visualize_fit_srtm(T,tacs,input,frames,roi_labels,results_dir)

fit_dir = sprintf('%s/fits',results_dir);
if(~exist(fit_dir,'dir'))
    mkdir(fit_dir);
end
t = mean(frames,2);
cri = cumtrapz(t,input);
dt = [t(1); t(2:end)-t(1:end-1)];
M = length(t);

for i = 1:size(tacs,1)
    fig = figure('Visible','Off','Position',[100 100 700 400]);
    plot(t,input,'k--'); hold on;
    plot(t,tacs(i,:),'ko');
    k = table2array(T(i,:));
    y = simSRTM_1_0_0(k,t,input,cri,dt,M);
    plot(t,y,'k');
    xlabel('Time (min)'); ylabel('Radioactivity concentration');
    title(roi_labels{i});
    img_name = sprintf('%s/%s.png',fit_dir,roi_labels{i});
    a = annotation('textbox', [0.5 0.13 0.1 0.1], 'String',...
        sprintf('R1 = %.2f; k2 = %.2f; BPnd = %.2f',...
        k(1),k(2),k(3)));
    set(a,'Color','k','LineStyle','none','FontSize',12);
    print('-noui',img_name,'-dpng');
    close(fig);
end

fname = sprintf('%s/modelfits.mat',results_dir);
s = struct('modelfits',y,'tacs',tacs,'input',input,'frames',frames,'t',t,'roi_labels',{roi_labels}); 
save(fname,'-struct','s');

end