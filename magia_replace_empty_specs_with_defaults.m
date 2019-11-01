function corrected_specs = magia_replace_empty_specs_with_defaults(specs)
% Replaces the empty fields in specs.magia with Magia's default options.
% Defaults have only been defined for options that are related to
% Magia-processing (e.g. width of smoothing kernel, motion correction
% parameters, etc.).

magia_specs = fieldnames(specs.magia);
N = length(magia_specs);
corrected_specs = specs;
for i = 1:N
    field_name = magia_specs{i};
    val = specs.magia.(field_name);
    if(isempty(val) || any(isnan(val)) || strcmp(val,'null'))
        corrected_specs.magia.(field_name) = magia_get_default_specs(field_name,specs.study.tracer);
    end
end

other_specs = setdiff({'mc_ref_frame' 'mc_fwhm' 'mc_rtm' 'mc_excluded_frames'},magia_specs);
M = length(other_specs);
for i = 1:M
    field_name = other_specs{i};
    corrected_specs.magia.(field_name) = magia_get_default_specs(field_name,specs.study.tracer);
end

end