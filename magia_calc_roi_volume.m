function volumes = magia_calc_roi_volume(mask_files)

if(ischar(mask_files))
    mask_files = cell(mask_files);
end

volumes = nan(length(mask_files),1);

for i = 1:length(mask_files)
    V = spm_vol(mask_files{i});
    if(i==1)
        voxel_size = prod(sqrt(sum((V.mat(1:3,1:3)).^2,1)));
    end
    mask = spm_read_vols(V);
    volumes(i) = sum(mask(:) > 0) * voxel_size;
end

end