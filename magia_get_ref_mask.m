function [ref_mask,roi_masks,roi_labels] = magia_get_ref_mask(roi_masks,study_specs)

[~,roi_names] = cellfun(@fileparts,roi_masks,'UniformOutput',false);
ref_name = magia_get_ref_region(study_specs.tracer);
ref_idx = strcmpi(roi_names,ref_name.label);
ref_mask = roi_masks{ref_idx};
roi_masks(ref_idx) = [];

[~,roi_labels] = cellfun(@fileparts,roi_masks,'UniformOutput',false);

end