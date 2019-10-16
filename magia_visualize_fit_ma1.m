function magia_visualize_fit_ma1(tacs,b1,b2,auc_input,auc_pet,k,frames,roi_labels,results_dir)

fit_dir = sprintf('%s/fits',results_dir);
if(~exist(fit_dir,'dir'))
    mkdir(fit_dir);
end

t = mean(frames,2);

Vt = -b1./b2;
intercept = 1./b2;

for i = 1:size(tacs,1)
    y = tacs(i,:);
    fig = figure('Visible','Off','Position',[100 100 700 400]);
    plot(t,y,'ko'); hold on;
    plot(t(k),y(k),'ro');
    yy = b1(i)*auc_input + b2(i)*auc_pet(:,i);
    plot(t,yy,'r');
    img_name = sprintf('%s/%s.png',fit_dir,roi_labels{i});
    xlabel('Time (min)');
    ylabel('Radioactivity concentration');
    title(roi_labels{i});
    a = annotation('textbox', [0.6 0.13 0.1 0.1], 'String',...
        sprintf('Vt = %.2f; intercept = %.2f',round(Vt(i),2),round(intercept(i),2)));
    set(a,'Color','k','LineStyle','none','FontSize',12);
    print('-noui',img_name,'-dpng');
    close(fig);
end

end