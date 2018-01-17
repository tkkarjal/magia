function modeling_options = aivo_read_fur_modeling_options(subject_id)

conn = check_megabase_conn();
if(isempty(conn))
    conn = aivo_connect();
end

cols = columns(conn,'megapet','aivo','fur');
cols = setdiff(cols,'tracer','stable');
M = length(cols);
select_statement = 'SELECT * FROM "megabase"."aivo".fur';
where_statement = sprintf('WHERE fur.image_id = %s%s%s',char(39),lower(subject_id),char(39));

q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);

curs = exec(conn,q);
curs = fetch(curs);
close(curs);
value = curs.Data;
close(conn);

modeling_options.model = 'fur';
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
                start_time = magia_get_fur_default_options(tracer,var);
            end
        case 'ic'
            ic = value{1,i};
            if(isnan(ic))
                ic = magia_get_fur_default_options(tracer,var);
            end
    end
end

modeling_options.start_time = start_time;
modeling_options.ic = ic;

aivo_set_modeling_options(subject_id,modeling_options);

end