function modeling_options = aivo_read_2tcm_modeling_options(subject_id)

conn = check_megabase_conn();
if(isempty(conn))
    conn = aivo_connect();
end

cols = columns(conn,'megapet','aivo2','two_tcm');
cols = setdiff(cols,'tracer','stable');
M = length(cols);
select_statement = 'SELECT * FROM "megabase"."aivo2".two_tcm';
where_statement = sprintf('WHERE two_tcm.image_id = %s%s%s',char(39),lower(subject_id),char(39));

q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);

curs = exec(conn,q);
curs = fetch(curs);
close(curs);
value = curs.Data;
close(conn);

modeling_options.model = 'two_tcm';
tracer = aivo_get_info(subject_id,'tracer');
if(iscell(tracer))
    tracer = tracer{1};
end

for i = 2:M
    var = cols{i};
    switch var
        case 'k1_lb'
            k1_lb = value{1,i};
            if(isnan(k1_lb))
                k1_lb = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k1_ub'
            k1_ub = value{1,i};
            if(isnan(k1_ub))
                k1_ub = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k1k2_lb'
            k1k2_lb = value{1,i};
            if(isnan(k1k2_lb))
                k1k2_lb = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k1k2_ub'
            k1k2_ub = value{1,i};
            if(isnan(k1k2_ub))
                k1k2_ub = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k3_lb'
            k3_lb = value{1,i};
            if(isnan(k3_lb))
                k3_lb = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k3_ub'
            k3_ub = value{1,i};
            if(isnan(k3_ub))
                k3_ub = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k3k4_lb'
            k3k4_lb = value{1,i};
            if(isnan(k3k4_lb))
                k3k4_lb = magia_get_2tcm_default_options(tracer,var);
            end
        case 'k3k4_ub'
            k3k4_ub = value{1,i};
            if(isnan(k3k4_ub))
                k3k4_ub = magia_get_2tcm_default_options(tracer,var);
            end
        case 'vb_lb'
            vb_lb = value{1,i};
            if(isnan(vb_lb))
                vb_lb = magia_get_2tcm_default_options(tracer,var);
            end
        case 'vb_ub'
            vb_ub = value{1,i};
            if(isnan(vb_ub))
                vb_ub = magia_get_2tcm_default_options(tracer,var);
            end
    end
end

modeling_options.k1_lb = k1_lb;
modeling_options.k1_ub = k1_ub;
modeling_options.k1k2_lb = k1k2_lb;
modeling_options.k1k2_ub = k1k2_ub;
modeling_options.k3_lb = k3_lb;
modeling_options.k3_ub = k3_ub;
modeling_options.k3k4_lb = k3k4_lb;
modeling_options.k3k4_ub = k3k4_ub;
modeling_options.vb_lb = vb_lb;
modeling_options.vb_ub = vb_ub;

aivo_set_modeling_options(subject_id,modeling_options);

end