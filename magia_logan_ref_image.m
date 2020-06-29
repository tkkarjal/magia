function parametric_images = magia_logan_ref_image(pet_filename,input,frames,brainmask_filename,start_time,end_time,refk2,outputdir)

V = spm_vol(pet_filename);
pet_img = spm_read_vols(V);
pet_img = reshape(pet_img,[prod(V(1).dim(1:3)) size(V,1)])';
V = spm_vol(brainmask_filename);
mask = spm_read_vols(V) > 0;
non_nan_mask = reshape(~any(isnan(pet_img)),V.dim);
% non_zero_mask = reshape(~any(pet_img <= 0),V.dim);
% mask = mask & non_nan_mask & non_zero_mask;
mask = mask & non_nan_mask;
pet_img = pet_img(:,mask);

fprintf('Starting Logan fit with reference input to %.0f voxels...',sum(mask(:)));
[DVR,intercept] = magia_fit_logan_ref(pet_img,input,frames,start_time,end_time,refk2);
fprintf(' Ready.\n');

DVR_img = zeros(size(mask));
intercept_img = DVR_img;

DVR_img(mask) = DVR;
intercept_img(mask) = intercept;

parametric_images = cell(2,1);

[~,filename] = fileparts(pet_filename);

V.dt = [spm_type('int16') 0];
V.pinfo = [inf inf inf]';

if(end_time > 0)
    niftiname = fullfile(outputdir,[filename '_Logan_ref_DVR_' int2str(start_time) '_' int2str(end_time) '.nii']);
else
    niftiname = fullfile(outputdir,[filename '_Logan_ref_DVR_' int2str(start_time) '.nii']);
end

V.fname = niftiname;
V.private.dat.fname = niftiname; 
spm_write_vol(V,DVR_img);

parametric_images{1} = niftiname;

niftiname = fullfile(outputdir,[filename '_Logan_ref_intercept' int2str(start_time) '_' int2str(end_time) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname;  
spm_write_vol(V,intercept_img);

parametric_images{2} = niftiname;

end 
