function magia_write_specs(subject,specs)

data_path = getenv('DATA_DIR');
subject_dir = sprintf('%s/%s',data_path,subject);
specs_file = sprintf('%s/specs_%s.txt',subject_dir,subject);

fid = fopen(specs_file,'w');

macro_fields = fieldnames(specs);
N1 = length(macro_fields);

for i = 1:N1
    S = specs.(macro_fields{i});
    micro_fields = fieldnames(S);
    N2 = length(micro_fields);
    for j = 1:N2
        field = micro_fields{j};
        value = S.(field);
        if(strcmp(field,'frames'))
            value = get_frame_string(value);
        end
        if(isnumeric(value))
            value = num2str(value);
        end
        fprintf(fid,'%s: %s\n',field,value);
    end
end

fclose(fid);

end