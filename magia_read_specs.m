function specs = magia_read_specs(specs_file)
% Reads the specifications from the specs.txt file

fid = fopen(specs_file,'r');
l = fgetl(fid);
while(l ~= -1)
    split_idx = regexp(l,':');
    field_name = l(1:split_idx-1);
    value = l(split_idx+2:end);
    switch field_name
        case {'tracer' 'frames' 'weight' 'dose' 'scanner' 'mri_code'}
            specs.study.(field_name) = value;
        otherwise
            specs.magia.(field_name) = value;
    end
    l = fgetl(fid);
end

fclose(fid);

end