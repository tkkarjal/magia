function modeling_options = aivo_read_patlak_ref_modeling_options(subject_id)

conn = aivo_connect();

cols = aivo_columns(conn,'patlak_ref');
cols = setdiff(cols,'tracer','stable');
M = length(cols);
select_statement = 'SELECT * FROM "megabase"."aivo2".patlak_ref';
where_statement = sprintf('WHERE patlak_ref.image_id = %s%s%s',char(39),lower(subject_id),char(39));

q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);

curs = exec(conn,q);
curs = fetch(curs);
value = curs.Data;
close(curs);
close(conn);

modeling_options.model = 'patlak_ref';
tracer = aivo_get_info(subject_id,'tracer');
if(iscell(tracer))
    tracer = tracer{1};
end

for i = 2:M
    var = cols{i};
    switch var
        case 'start_time'
            start_time = value{1,i};
            if(isnan(start_time))
                start_time = magia_get_patlak_ref_default_options(tracer,var);
            end
        case 'end_time'
            end_time = value{1,i};
            if(isnan(end_time))
                end_time = magia_get_patlak_ref_default_options(tracer,var);
            end
        case 'filter_size'
            filter_size = value{1,i};
            if(isnan(filter_size))
                filter_size = magia_get_patlak_ref_default_options(tracer,var);
            end
    end
end

modeling_options.start_time = start_time;
modeling_options.end_time = end_time;
modeling_options.filter_size = filter_size;

aivo_set_modeling_options(subject_id,modeling_options);

end
