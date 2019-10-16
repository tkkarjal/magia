function parametric_images = magia_patlak_ref_image(pet_filename,ref_tac,frames,brainmask_filename,start_time,end_time,outputdir)

if(~end_time)
    end_time = frames(end,2);
end

V = spm_vol(pet_filename);
pet_img = spm_read_vols(V);
pet_img = reshape(pet_img,[prod(V(1).dim(1:3)) size(V,1)])';
V = spm_vol(brainmask_filename);
mask = spm_read_vols(V) > 0;
pet_img = pet_img(:,mask);

fprintf('Starting Patlak_ref fit to %.0f voxels...',sum(mask(:)));
[Ki_ref,intercept] = magia_fit_patlak_ref(ref_tac,pet_img,frames,start_time,end_time);
fprintf(' Ready.\n');

Ki_ref_img = zeros(size(mask));
intercept_img = Ki_ref_img;

Ki_ref_img(mask) = Ki_ref;
intercept_img(mask) = intercept;

parametric_images = cell(2,1);

[~,filename] = fileparts(pet_filename);

V.dt = [spm_type('int16') 0];
V.pinfo = [inf inf inf]';

niftiname = fullfile(outputdir,[filename '_Patlak_Ki_ref_' int2str(start_time) '_' int2str(end_time) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname; 
spm_write_vol(V,Ki_ref_img);

parametric_images{1} = niftiname;

niftiname = fullfile(outputdir,[filename '_Patlak_intercept' int2str(start_time) '_' int2str(end_time) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname;  
spm_write_vol(V,intercept_img);

parametric_images{2} = niftiname;

end 
