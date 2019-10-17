function aivo_set_modeling_options(subject_id,modeling_options)

conn = aivo_connect();

model = modeling_options.model;
cols = columns(conn,'megapet','aivo',model);
cols = setdiff(cols,'tracer','stable');
tb = sprintf('"megabase"."aivo".%s',model);
whereclause = sprintf('WHERE %s.image_id = %s%s%s',model,char(39),subject_id,char(39));

for i = 2:length(cols)
    field = cols{i};
    value = modeling_options.(field);
    update(conn,tb,{field},{value},whereclause);
end

close(conn);

end