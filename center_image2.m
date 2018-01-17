function W = center_image2(filename,tracer)

if(~ischar(filename))
    error('The input argument filename has to be a string.');
end

pet_template_dir = '/scratch/shared/megapet/templates';
pet_template_file = sprintf('%s/%s.nii',pet_template_dir,tracer);

V = spm_vol(filename);
N = length(V);
[p,n,e] = fileparts(filename);
sum_filename = fullfile(p,[n '_tempsum' e]);
img = spm_read_vols(V);
sum_img = sum(img,4);
V0 = V(1);
V0.fname = sum_filename;
spm_write_vol(V0,sum_img);

% Estimate orientation matrix using the sum image
if(exist(pet_template_file,'file'))
    cg_set_com_mod(sum_filename);
    spm_coregister_estimate(pet_template_file,sum_filename,'')
    W = spm_get_space(sum_filename);
else
    W = cg_set_com_mod(sum_filename);
end
delete(sum_filename);

% Use the orientation matrix for all the individual images
images = cellstr(spm_select('ExtFPList',p,[n e]));
for i = 1:N
    spm_get_space(images{i},W);
end

end