function new_ref_mask = shrink_oc_new(ref_mask,img)
% The function decreases the occipital cortex mask so that it is unlikely
% to include mu-opioid recpetors. The function operates in z-direction
% layer by layer and zeroes all voxels lateral to the lateral ventricles.
% Note that the function assumes the image to be in RAS orientation.
%
% Inputs:     ref_mask = a binary 3D mask specifying which voxels are part
%                        of occipital cortex and which are not.
%                  img = the image part of the aparc+aseg.mgz, given by
%                        FreeSurfer, converted to nifti format
%
% Output: new_ref_mask = the corrected (shrinked) occipital cortex mask

if(ischar(img))
    V = spm_vol(img);
    img = spm_read_vols(V);
    clear V
end

if(ischar(ref_mask))
    V = spm_vol(ref_mask);
    ref_mask = spm_read_vols(V);
    clear V
end

%% Lateral ventricle correction

lab = [4 43]; % left and right lateral ventricles
cor_mask = zeros(size(ref_mask));
min_xc = Inf;
max_xc = -Inf;
for slice = 1:size(img,3)
    img_slice = img(:,:,slice);
    [xc,~] = find(img_slice == lab(1) | img_slice == lab(2));
    if(~isempty(xc))
        if(min(xc) < min_xc)
            min_xc = min(xc);
        end
        if(max(xc) > max_xc)
            max_xc = max(xc);
        end
    end
end

cor_mask(min_xc:max_xc,:,:) = 1;
new_ref_mask = double(ref_mask).*cor_mask;

%% Add parts of the cuneus

lab = [1005 2005];

[~,~,cuneus_z] = ind2sub(size(img),find(img == lab(1) | img == lab(2)));
[~,~,oc_z] = ind2sub(size(img),find(new_ref_mask));

zc = intersect(cuneus_z,oc_z);

for slice = 1:length(zc)
    plane = squeeze(img(:,:,zc(slice)));
    cuneus = (plane == lab(1)) + (plane == lab(2));
    
    oc_slice = squeeze(new_ref_mask(:,:,zc(slice)));
    [~,oc_y] = find(oc_slice);
    cuneus(:,max(oc_y):end) = 0;
    
    new_ref_mask(:,:,zc(slice)) = new_ref_mask(:,:,zc(slice)) + double(logical(cuneus));
end

%% Remove the bottommost and topmost slices

[~,~,zc] = ind2sub(size(new_ref_mask),find(new_ref_mask));
zc = unique(zc);
M = length(zc); % M slices that have OC voxels
K = floor(M/6);
z_min = min(zc) + K;
new_ref_mask(:,:,1:z_min) = 0;
z_max = max(zc) - K;
new_ref_mask(:,:,z_max:end) = 0;

end
