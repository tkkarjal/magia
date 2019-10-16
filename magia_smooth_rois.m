function smoothed_roi_masks = magia_smooth_rois(roi_masks,roi_fwhm)
% Takes in ROI masks, smooths them with a Gaussian kernel of requested
% size, and thresholds them. The procedure essentially enlargens the
% original ROIs slightly.
%
% This function has been tested with roi_fwhm = 2 mm.

if(roi_fwhm == 0)
    warning('Requested smoothing of ROI masks with FWHM = 0 mm. Finishing without action.\n');
    smoothed_roi_masks = roi_masks;
else
    smoothed_roi_masks = smooth_img(roi_masks,roi_fwhm);
    N = length(smoothed_roi_masks);
    for i = 1:N
        V = spm_vol(roi_masks{i});
        img = spm_read_vols(V);
        maxval = max(img(:));
        thr = 0.1*maxval;
        clear V img maxval
        V = spm_vol(smoothed_roi_masks{i});
        img = spm_read_vols(V);
        mask = double(img > thr);
        spm_write_vol(V,mask);
    end
end

end
