function modeling_options = aivo_read_srtm_modeling_options(subject_id)

conn = check_megabase_conn();
if(isempty(conn))
    conn = aivo_connect();
end

cols = columns(conn,'megapet','aivo','srtm');
cols = setdiff(cols,'tracer','stable');
M = length(cols);
select_statement = 'SELECT * FROM "megabase"."aivo".srtm';
where_statement = sprintf('WHERE srtm.image_id = %s%s%s',char(39),lower(subject_id),char(39));

q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);

curs = exec(conn,q);
curs = fetch(curs);
close(curs);
value = curs.Data;
close(conn);

modeling_options.model = 'srtm';
tracer = aivo_get_info(subject_id,'tracer');
if(iscell(tracer))
    tracer = tracer{1};
end
modeling_options.lb = magia_get_srtm_default_options(tracer,'lb');
modeling_options.ub = magia_get_srtm_default_options(tracer,'ub');

for i = 2:M
    var = cols{i};
    switch var
        case 'theta3_lb'
            theta3_lb = value{1,i};
            if(isnan(theta3_lb))
                theta3_lb = magia_get_srtm_default_options(tracer,var);
            end
        case 'theta3_ub'
            theta3_ub = value{1,i};
            if(isnan(theta3_ub))
                theta3_ub = magia_get_srtm_default_options(tracer,var);
            end
        case 'nbases'
            nbases = value{1,i};
            if(isnan(nbases))
                nbases = magia_get_srtm_default_options(tracer,var);
            end
    end
end

modeling_options.theta3_lb = theta3_lb;
modeling_options.theta3_ub = theta3_ub;
modeling_options.nbases = nbases;

aivo_set_modeling_options(subject_id,modeling_options);

end