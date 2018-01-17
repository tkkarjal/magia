function [number_of_bad_volumes,proportion_of_bad_volumes] = motion_parameter_qc(subject)

data_path = getenv('DATA_DIR');

mp_file = sprintf('%s/%s/PET/rp_pet_%s.txt',data_path,subject,subject);
X = load(mp_file);
fs = aivo_get_info(subject,'frames');
frames = parse_frames_string(fs{1});
t = mean(frames,2);

tra_thr = 1;
rot_thr = 0.05;

fig = figure('Position',[860 707 1001 587],'Visible','Off');

for i = 1:6
    y = X(:,i);
    lb = min(y);
    ub = max(y);
    subplot(6,1,i);
    plot(t,y,'ko-','LineWidth',1); xlim([0 t(end)]);
    hold on;
    if(i<4)
        plot(t,tra_thr*ones(size(t)),'r--');
        plot(t,-tra_thr*ones(size(t)),'r--');
        ymin = min([lb -1.5*tra_thr]);
        ymax = max([ub 1.5*tra_thr]);
        ylim([ymin ymax]);
    else
        plot(t,rot_thr*ones(size(t)),'r--');
        plot(t,-rot_thr*ones(size(t)),'r--');
        ymin = min([lb -1.5*rot_thr]);
        ymax = max([ub 1.5*rot_thr]);
        ylim([ymin ymax]);
    end
    switch i
        case 1
            ylab = 'x (mm)';
            title(sprintf('SPM Motion parameters (%s)',subject));
            set(gca,'xtick',[]);
            set(gca,'xticklabel',[]);
        case 2
            ylab = 'y (mm)';
            set(gca,'xtick',[]);
            set(gca,'xticklabel',[]);
        case 3
            ylab = 'z (mm)';
            set(gca,'xtick',[]);
            set(gca,'xticklabel',[]);
        case 4
            ylab = 'x (rad)';
            set(gca,'xtick',[]);
            set(gca,'xticklabel',[]);
        case 5
            ylab = 'y (rad)';
            set(gca,'xtick',[]);
            set(gca,'xticklabel',[]);
        case 6
            ylab = 'z (rad)';
            xlabel('Time (min)');
    end
    ylabel(ylab); box off;
end

add_to_qc_pic(subject,fig);

Z = abs(X);
number_of_bad_volumes = sum(sum(Z(:,1:3) > 1,2) > 0 | sum(Z(:,4:6) > 0.05,2));
proportion_of_bad_volumes = number_of_bad_volumes/length(t);

end