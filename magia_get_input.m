function input = magia_get_input(subject,input_type)

if(~strcmpi(input_type,'plasma') && ~strcmpi(input_type,'blood') && ~strcmpi(input_type,'plasma&blood'))
    error('%s: Input type must be either ''plasma, ''blood or ''plasma&blood.',subject);
end

input_folder = sprintf('%s/%s/%s',getenv('DATA_DIR'),subject,input_type);
f = get_filenames(input_folder,'*.');
if(isempty(f))
    error('%s: Could not find input data from %s',subject,input_folder);
else
    % Read input
    input = magia_read_input(f);
    
    % Visualize input
    fig = figure('Visible','Off'); clf;
    plot(input(:,1),input(:,2),'ko-');
    xlabel('Time (min)'); box off;
    if(max(input(:,2) < 100))
        ylabel('Radioactivity concentration (kBq/ml)');
    else
        ylabel('Radioactivity concentration (Bq/ml)');
    end
    title(sprintf('%s input curve (%s)',input_type,subject));
    
    % Save figure
    img_name = sprintf('%s/%s_activity.png',input_folder,input_type);
    if(exist(img_name,'file'))
        delete(img_name);
    end
    print('-noui',img_name,'-dpng');
    close(fig);
end

end