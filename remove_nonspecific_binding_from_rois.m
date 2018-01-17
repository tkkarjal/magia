function remove_nonspecific_binding_from_rois(original_roi_masks,specific_binding_mask,varargin)

if(ischar(specific_binding_mask))
    V = spm_vol(specific_binding_mask);
    specific_binding_mask = spm_read_vols(V);
    clear V
end

if(nargin==3)
    outdir = varargin{1};
end

if(iscell(original_roi_masks))
    for r = 1:length(original_roi_masks)
        V = spm_vol(original_roi_masks{r});
        img = uint8(specific_binding_mask.*spm_read_vols(V));
        if(nargin==3)
            [~,name] = fileparts(V.fname);
            V.fname = fullfile(outdir,[name '.nii']);
        end
        spm_write_vol(V,img);
    end
elseif(ischar(original_roi_masks))
    V = spm_vol(original_roi_masks);
    img = uint8(specific_binding_mask.*spm_read_vols(V));
    if(nargin==3)
        [~,name] = fileparts(V.fname);
        V.fname = fullfile(outdir,[name '.nii']);
    end
    spm_write_vol(V,img);
else
    error('original_roi_masks must be a cell array or a string.');
end

end