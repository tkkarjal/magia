function varargout = get_roi_masks(atlas_dir,varargin)

roi_masks = get_filenames(atlas_dir,'*.nii');

if(nargin > 1)
    data_path = getenv('DATA_DIR');
    subject = varargin{1};
    subject_mask_dir = sprintf('%s/%s/masks',data_path,subject);
    mkdir(subject_mask_dir);
    if(nargin > 2)
        ref_region = varargin{2};
        ref_idx = ~cellfun(@isempty,regexp(roi_masks,ref_region));
        ref_mask = roi_masks{ref_idx};
        roi_masks(ref_idx) = [];
        copyfile(ref_mask,subject_mask_dir,'f')
        [~,n] = fileparts(ref_mask);
        ref_mask = fullfile(subject_mask_dir,[n '.nii']);
        varargout{2} = ref_mask;
    end
    for j = 1:length(roi_masks)
        copyfile(roi_masks{j},subject_mask_dir,'f');
        [~,n] = fileparts(roi_masks{j});
        roi_masks{j} = fullfile(subject_mask_dir,[n '.nii']);
    end
end

varargout{1} = roi_masks;

end
