function magia_write_modeling_options(subject,modeling_options)

data_path = getenv('DATA_DIR');
modeling_options_file = sprintf('%s/%s/modeling_options_%s.txt',data_path,subject,subject);
model = modeling_options.model;
modeling_options = rmfield(modeling_options,'model');
field_names = fieldnames(modeling_options);
N = length(field_names);

fid = fopen(modeling_options_file,'w');
fprintf(fid,'model,%s\n',model);

for i = 1:N
    f = field_names{i};
    v = modeling_options.(f);
    if(ischar(v))
    fprintf(fid,'%s,%s\n',f,v);
    else
        fprintf(fid,'%s',f);
        M = length(v);
        for j = 1:M
            fprintf(fid,',%f',v(j));
        end
        fprintf(fid,'\n');
    end
end

fclose(fid);

end