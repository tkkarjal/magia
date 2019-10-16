function parametric_images = magia_patlak_image(pet_filename,input,frames,brainmask_filename,start_time,end_frame,outputdir)

if(end_frame == 0)
    end_frame = size(frames,1);
end

V = spm_vol(pet_filename);
pet_img = spm_read_vols(V);
pet_img = reshape(pet_img,[prod(V(1).dim(1:3)) size(V,1)])';
V = spm_vol(brainmask_filename);
mask = spm_read_vols(V) > 0;
pet_img = pet_img(:,mask);

fprintf('Starting Patlak fit to %.0f voxels...',sum(mask(:)));
[Ki,intercept] = magia_fit_patlak(input,pet_img,frames,start_time,end_frame);
fprintf(' Ready.\n');

Ki_img = zeros(size(mask));
intercept_img = Ki_img;

Ki_img(mask) = Ki;
intercept_img(mask) = intercept;

parametric_images = cell(2,1);

[~,filename] = fileparts(pet_filename);

V.dt = [spm_type('int16') 0];
V.pinfo = [inf inf inf]';

niftiname = fullfile(outputdir,[filename '_Patlak_Ki_' int2str(start_time) '_' int2str(end_frame) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname; 
spm_write_vol(V,Ki_img);

parametric_images{1} = niftiname;

niftiname = fullfile(outputdir,[filename '_Patlak_intercept' int2str(start_time) '_' int2str(end_frame) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname;  
spm_write_vol(V,intercept_img);

parametric_images{2} = niftiname;

end 
