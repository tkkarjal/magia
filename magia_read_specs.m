function specs = magia_read_specs(specs_file)
% Reads the specifications from the specs.txt file

fid = fopen(specs_file,'r');
l = fgetl(fid);
while(l ~= -1)
    split_idx = regexp(l,':');
    field_name = l(1:split_idx-1);
    value = l(split_idx+2:end);
    if(ismember(field_name,{'dose' 'weight' 'cpi' 'dc' 'rc' 'fwhm_pre' 'fwhm_post' 'fwhm_roi' 'cut_time' 'mc_fwhm' 'mc_rtm' 'mc_ref_frame'}))
        value = str2double(value);
    end
    switch field_name
        case {'tracer' 'frames' 'weight' 'dose' 'scanner' 'mri_code'}
            if(strcmp(field_name,'frames'))
                value = parse_frames_string(value);
            end
            specs.study.(field_name) = value;
        otherwise
            specs.magia.(field_name) = value;
    end
    l = fgetl(fid);
end

fclose(fid);

end
