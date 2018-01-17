function X = get_voxel_time_series(image)

if(ischar(image))
    V = spm_vol(image);
    image = spm_read_vols(V);
    clear V
end

S=size(image);
X=reshape(image,prod(S(1:3)),S(4))';

end
