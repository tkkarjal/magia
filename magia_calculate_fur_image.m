function fur_image_file = magia_calculate_fur_image(input,frames,start_time,ic,pet_filename,brainmask,outputdir)

[~,name] = fileparts(pet_filename);
fur_image_file = sprintf('%s/%s_fur.nii',outputdir,name);
I = calculate_fur_integral(input,frames);

W = spm_vol(brainmask);
mask = spm_read_vols(W);

k = frames(:,1) >= start_time;
if(any(k))
    V = spm_vol(pet_filename);
    img = spm_read_vols(V);
    img = mean(img(:,:,:,k),4,'omitnan');
    fur_img = mask.*(img-ic)./I;
    if(max(fur_img(:))>10)
        fur_img = fur_img*0.001;
    elseif(max(fur_img(:))<1e-3)
        fur_img = fur_img*1000;
    end
    W = V(1);
    W.fname = fur_image_file;
    W.dt = [spm_type('int16') spm_platform('bigend')];
    W.pinfo = [Inf Inf Inf]';
    spm_write_vol(W,fur_img);
else
    error('Could not calculate FUR image for %s because none of the frames start after the parameter start_time %d min.',name,start_time);
end
        
end
