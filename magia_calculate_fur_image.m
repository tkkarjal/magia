function fur_image_file = magia_calculate_fur_image(input,frames,start_time,end_time,ic,pet_filename,brainmask,outputdir)

[~,name] = fileparts(pet_filename);
fur_image_file = sprintf('%s/%s_fur.nii',outputdir,name);

% Select the frames between start_time and end_time
if(end_time == 0)
    end_time = frames(end);
end

k = frames(:,1) >= start_time & frames(:,2) <= end_time;

if(any(k))
    frames = frames(k,:);
    V = spm_vol(pet_filename);
    img = spm_read_vols(V);
    if(size(img,4) > 1)
        img = img(:,:,:,k);
        img = mean(img,4,'omitnan');
    end
else
    error('Could not calculate FUR image for %s because there are no frames between start_time and end_time.',name);
end

% Calculate FUR integral
I = calculate_fur_integral(input,frames);

% Load brainmask
W = spm_vol(brainmask);
mask = spm_read_vols(W);

if(ic)
    tmid = 0.5*(frames(1)+frames(end));
    cp = spline(input(:,1),input(:,2),tmid);
    fur_img = (mask.*(img-ic*cp))./I;
else
    fur_img = (mask.*img)./I;
end

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

end