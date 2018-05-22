function input = magia_read_plasma(subject,pet_bq)

data_path = getenv('DATA_DIR');
d = sprintf('%s/%s/plasma',data_path,subject);
if(~exist(d,'dir'))
    error('Could not find plasma data for %s.',subject);
end

f = get_filenames(d,'*.');
if(~isempty(f))
    f = f{1};
    [~,~,ext] = fileparts(f);
    if(strcmpi(ext,'.kbq'))
        k = 1;
    elseif(strcmpi(ext,'.bq'))
        k = 0;
    else
        k = 1;
    end
    input = metpet_read_plasma_data(f);
    if(input(1,1) > 0)
        input = [0 0;input];
    end
    maxval_plasma = max(input(:,2));
    if(pet_bq && maxval_plasma < 500)
        input(:,2) = input(:,2)*1000;
    elseif(~pet_bq && maxval_plasma > 500)
        input(:,2) = input(:,2)*0.001;
    end
    fig = figure('Visible','Off'); clf;
    plot(input(:,1),input(:,2),'ko-');
    xlabel('Time (min)'); box off;
    if(k)
        ylabel('Radioactivity concentration (kBq/cc)');
    else
        ylabel('Radioactivity concentration (Bq/cc)');
    end
    title(sprintf('Plasma activity (%s)',subject));
    img_name = sprintf('%s/plasma_activity.png',fileparts(f));
    if(exist(img_name,'file'))
        delete(img_name);
    end
    print('-noui',img_name,'-dpng');
    close(fig);
else
    error('Could not find plasma data for %s.',subject);
end

end