function brainmask_file = magia_create_brainmask(meanpet_file,fwhm_pre)
% Creates a brain mask based on the mean PET image. First, if the mean PET
% image has not been smoothed (fwhm_pre = 0), then the mean PET image is
% slightly smoothed. Second, a kernel density of the radioactivity
% concentration distribution within the image is estimated (excluding
% zeros). The distribution always peaks at the lowest values, after which
% it more or less plateaus. The beginning of the plateau is used as the
% radioactivity-concentration-threshold. This threshold is very
% conservative and the masks tend to extend markedly outside brain tissue.
% Despite the conservative thresholding, the procedure significantly
% reduces the number of voxels where model estimation for parametric images
% will be done, speeding up the calculation of parametric images.

% Tomi Karjalainen, September 13th, 2019

if(~exist(meanpet_file,'file'))
    error('Could not create a brainmask because the image file %s could not be found.',meanpet_file);
end

V = spm_vol(meanpet_file);
meanpet_image = spm_read_vols(V);

if(~fwhm_pre)
    for z = 1:size(meanpet_image,3)
        slice = squeeze(meanpet_image(:,:,z));
        smoothed_slice = spm_conv(slice,3);
        meanpet_image(:,:,z) = smoothed_slice;
    end
end

v = meanpet_image(:);
v = v(v>0);
[n,x] = ksdensity(v);
% If the distribution increases at the very beginning, get rid of the first
% peak
while(n(2) > n(1))
    n(1) = [];
    x(1) = [];
end
dn = diff(n);
idx = find(dn>0,1,'first');
if(~isempty(idx))
    thr = x(idx);
    brainmask = double(meanpet_image > thr);
    outdir = fileparts(meanpet_file);
    brainmask_file = sprintf('%s/brainmask.nii',outdir);
    V.fname = brainmask_file;
    V.dt = [spm_type('int16') spm_platform('bigend')];
    V.pinfo = [Inf Inf Inf]';
    spm_write_vol(V,brainmask);
else
    error('Could not create brainmask from the image file %s.',meanpet_file);
end

end