function ref_mask = magia_create_fs_ref_mask(seg_file,ref_region)

data_path = getenv('DATA_DIR');

V = spm_vol(seg_file);
seg_img = spm_read_vols(V);
dim = V.dim;

idx = regexp(seg_file,'/');
subject = seg_file(idx(end-2)+1:idx(end-1)-1);
mask_dir = sprintf('%s/%s/masks',data_path,subject);

V.dt = [spm_type('uint8') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';

mask = uint8(zeros(dim));
for j = 1:length(ref_region.codes)
    mask = mask + uint8(seg_img==ref_region.codes(j));
end

mask = uint8(logical(mask));
if(any(mask(:)))
    V.fname = [mask_dir filesep 'ref_region.nii'];
    spm_write_vol(V,mask);
    ref_mask = V.fname;
else
    error('%s: Could not find the specified reference region codes from the seg-file %s.',subject,seg_file);
end

end