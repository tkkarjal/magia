function [roi_masks,varargout] = create_roi_masks2(seg_file,roi_info,varargin)

data_path = getenv('DATA_DIR');

if(nargin==3)
    ref_region = varargin{1};
end

V = spm_vol(seg_file);
seg_img = spm_read_vols(V);
dim = V.dim;
N = length(roi_info.labels);

idx = regexp(seg_file,'/');
subject = seg_file(idx(end-2)+1:idx(end-1)-1);
mask_dir = sprintf('%s/%s/masks',data_path,subject);

if(~exist(mask_dir,'dir'))
    mkdir(mask_dir);
end

roi_masks = cell(N,1);
V.dt = [spm_type('uint8') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';

for i = 1:N
    codes = roi_info.codes{i};
    mask = uint8(zeros(dim));
    for j = 1:length(codes)
        mask = mask + uint8(seg_img==codes(j));
    end
    mask = uint8(logical(mask));
    V.fname = [mask_dir filesep roi_info.labels{i} '.nii'];
    roi_masks{i} = V.fname;
    spm_write_vol(V,mask);
    if(sum(mask(:)) == 0)
        warning('%s: Empty ROI mask file %s\n',subject,V.fname);
    end
end

if(nargin==3)
    mask = uint8(zeros(dim));
    for j = 1:length(ref_region.codes)
        mask = mask + uint8(seg_img==ref_region.codes(j));
    end
    
    mask = uint8(logical(mask));
    V.fname = [mask_dir filesep 'ref_region.nii'];
    spm_write_vol(V,mask);
    varargout{1} = V.fname;
end

end