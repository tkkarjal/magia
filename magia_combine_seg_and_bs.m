function magia_combine_seg_and_bs(seg_file,bs_fs_file)

p = fileparts(seg_file);
bs_nii_file = sprintf('%s/bs_seg.nii',p);

cmd = sprintf('mri_convert --out_orientation RAS -rt nearest %s %s',bs_fs_file,bs_nii_file);
system(cmd);

V_bs = spm_vol(bs_nii_file);
V_seg = spm_vol(seg_file);

bs_img = spm_read_vols(V_bs);
seg_img = spm_read_vols(V_seg);

bs_idx = logical(bs_img);

seg_img(bs_idx) = bs_img(bs_idx);
spm_write_vol(V_seg,seg_img);

end
