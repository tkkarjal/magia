function [I, modeling_options] = magia_metadata_from_aivo(image_id)
% Reads from AIVO the metadata and modeling options that MAGIA needs for
% processing a PET study.

magia_fields = {'tracer' 'frames' 'use_mri' 'mri' 'plasma' 'rc' 'dynamic' 'dc' 'fwhm'};
M = length(magia_fields);

for i = 1:M
    field = magia_fields{i};
    val = aivo_get_info(image_id,field);
    if(iscell(val))
        val = val{1};
    end
    I.(field) = val;
end

modeling_options = aivo_read_modeling_options(image_id);

end
