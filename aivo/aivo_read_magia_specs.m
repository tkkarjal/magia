function specs = aivo_read_magia_specs(image_id)

if(iscell(image_id))
    N = length(image_id);
    specs = cell(N,1);
    conn = aivo_connect();
    for i = 1:N
        specs{i} = aivo_read_magia_specs(image_id{i});
    end
else
    conn = aivo_connect();
    
    q = sprintf('SELECT * FROM megabase.aivo2.magia WHERE image_id = ''%s''',image_id);
    curs = exec(conn,q);
    curs = fetch(curs);
    value = curs.Data;
    close(curs);
    
    magia_cols = columns(conn,'megabase','aivo2','magia');
    [magia_cols,idx] = setdiff(magia_cols,'image_id');
    value = value(idx);
    
    n_cols = length(magia_cols);
    
    for i = 1:n_cols
        col = magia_cols{i};
        specs.magia.(col) = value{i};
    end
    
    q = sprintf('SELECT tracer,frames,dose,scanner,mri_code FROM megabase.aivo2.study WHERE image_id = ''%s''',image_id);
    curs = exec(conn,q);
    curs = fetch(curs);
    value = curs.Data;
    close(curs);
    
    study_cols = {'tracer' 'frames' 'dose' 'scanner' 'mri_code'};
    [study_cols,idx] = setdiff(study_cols,'image_id');
    value = value(idx);
    
    n_cols = length(study_cols);
    
    for i = 1:n_cols
        col = study_cols{i};
        if(strcmp(col,'frames'))
            specs.study.(col) = parse_frames_string(value{i});
        else
            specs.study.(col) = value{i};
        end
    end
    
    specs.study.glucose = aivo_get_info(image_id,'glucose');
    specs.study.weight = aivo_get_info(image_id,'weight');
    
end

close(conn);

end