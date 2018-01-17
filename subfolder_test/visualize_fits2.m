function visualize_fits(T,tacs,input,frames,modeling_options,roi_info,results_dir)

model = modeling_options.model;
N = size(tacs,1);

idx = regexp(results_dir,'/');
subject = results_dir(idx(end-1)+1:idx(end)-1);

switch lower(model)
    case 'srtm'
        fit_dir = sprintf('%s/fits',results_dir);
        if(~exist(fit_dir,'dir'))
            mkdir(fit_dir);
        end
        t = mean(frames,2);
        cri = cumtrapz(t,input);
        dt = [t(1); t(2:end)-t(1:end-1)];
        M = length(t);
        for i = 1:N
            fig = figure('Visible','Off','Position',[100 100 700 400]); plot(t,input,'k--'); hold on;
            plot(t,tacs(i,:),'ko');
            k = table2array(T(i,:));
            y = simSRTM_1_0_0(k,t,input,cri,dt,M);
            plot(t,y,'k');
            xlabel('Time (min)'); ylabel('Radioactivity concentration');
            title(roi_info.labels{i});
            img_name = sprintf('%s/%s.png',fit_dir,roi_info.labels{i});
            a = annotation('textbox', [0.5 0.13 0.1 0.1], 'String',...
                sprintf('R1 = %.2f; k2 = %.2f; BPnd = %.2f',...
                k(1),k(2),k(3)));
            set(a,'Color','k','LineStyle','none','FontSize',12);
            print('-noui',img_name,'-dpng');
            add_to_qc_pic(subject,fig);
            close(fig);
        end
    case 'patlak'
        fit_dir = sprintf('%s/fits',results_dir);
        if(~exist(fit_dir,'dir'))
            mkdir(fit_dir);
        end
        startTime = modeling_options.start_time;
        cutFrame = modeling_options.end_frame;
        if(cutFrame==0)
            cutFrame = size(frames,1);
        end
        for i = 1:N
            [Ki,V0,x,y,~,yy] = metpet_fit_patlak(input,tacs(i,:),frames,startTime,cutFrame);
            fig = figure('Visible','Off','Position',[100 100 700 400]);
            plot(x,y,'ko'); hold on; plot(x,yy,'k');
            img_name = sprintf('%s/%s.png',fit_dir,roi_info.labels{i});
            xlabel('\int_0^t C_p(\tau) d\tau / C_p(t) (min)');
            ylabel('C_r(t) / C_p(t) (unitless)');
            title(roi_info.labels{i});
            a = annotation('textbox', [0.6 0.13 0.1 0.1], 'String',...
                sprintf('K_i = %.4f; V0 = %.2f',round(Ki,4),round(V0,2)));
            set(a,'Color','k','LineStyle','none','FontSize',12);
            print('-noui',img_name,'-dpng');
            add_to_qc_pic(subject,fig);
            close(fig);
        end
    case 'patlak_ref'
        fit_dir = sprintf('%s/fits',results_dir);
        if(~exist(fit_dir,'dir'))
            mkdir(fit_dir);
        end
        startTime = modeling_options.start_time;
        cutTime = modeling_options.cut_time;
        if(~cutTime)
            cutTime = frames(end,2);
        end
        for i = 1:N
            [Ki,V0,x,y,k,yy] = magia_fit_patlak_ref(input,tacs(i,:),frames,startTime,cutTime);
            fig = figure('Visible','Off','Position',[100 100 700 400]);
            plot(x,y,'ko'); hold on; plot(x(k),y(k),'ro'); plot(x,yy,'k');
            img_name = sprintf('%s/%s.png',fit_dir,roi_info.labels{i});
            xlabel('\int_0^t C_r(\tau) d\tau / C_r(t) (min)');
            ylabel('C_t(t) / C_r(t) (unitless)');
            title(roi_info.labels{i});
            a = annotation('textbox', [0.6 0.13 0.1 0.1], 'String',...
                sprintf('K_i = %.4f; V0 = %.2f',round(Ki,4),round(V0,2)));
            set(a,'Color','k','LineStyle','none','FontSize',12);
            print('-noui',img_name,'-dpng');
            add_to_qc_pic(subject,fig);
            close(fig);
        end
    case {'fur','auc_ratio','static_ratio'}
        % Fit visualization not really applicable to these "models"
    otherwise
        warning('Fit visualization has not been implemented for %s.',model);
end

end