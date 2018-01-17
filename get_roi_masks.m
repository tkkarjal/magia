function varargout = get_roi_masks(mask_dir,varargin)

roi_masks = get_filenames(mask_dir,'*.nii');
varargout{1} = roi_masks;    
if(nargin==2)
    ref_region = varargin{1};
    ref_idx = find(1-cellfun(@isempty,regexp(roi_masks,ref_region)));
    ref_mask = roi_masks{ref_idx};
    roi_masks(ref_idx) = [];
    varargout{1} = roi_masks;   
    varargout{2} = ref_mask;
end

end