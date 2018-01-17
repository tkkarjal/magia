function ratio_image_file = magia_suvr_dyn_image(startTime,endTime,input,frames,pet_filename,brainmask,outputdir)

start_frame = find(frames(:,1)>=startTime,1,'first');
end_frame = find(frames(:,2)<=endTime,1,'last');

t = mean(frames,2);
tx = t(start_frame:end_frame);

ref_auc = trapz(tx,input(start_frame:end_frame));

V = spm_vol(brainmask);
mask = spm_read_vols(V);
I = find(mask>0);

auc_img = zeros(V.dim);

tacs = get_voxel_time_series(pet_filename)';
tacs = tacs(:,start_frame:end_frame);

for i = 1:size(I,1)
    auc_img(I(i)) = trapz(tx,tacs(I(i),:));
end

ratio_image = auc_img / ref_auc;
[~,n] = fileparts(pet_filename);
V.fname = sprintf('%s/%s_suvr_dyn.nii',outputdir,n);
V.dt = [spm_type('int16') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';
spm_write_vol(V,ratio_image);

ratio_image_file = V.fname;

end