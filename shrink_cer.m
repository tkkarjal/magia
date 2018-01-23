function new_ref_mask = shrink_cer(old_ref_mask,voxel_sizes)
% The function decreases the cerebellum mask so that
% i) spillover from occipital cortex, and ii) effects of cerebellar vermis
% are minimized.
%
% The function operates in z-direction slice by slice and removes the
% central (midline +/- 12 mm) voxels. After that the topmost and bottommost
% voxels (10 mm from the bottom, 20 mm from the top) are removed.
%
% Note that the function assumes the image to be in RAS orientation.
%
% Inputs:     old_ref_mask = a binary 3D mask specifying which voxels
%                            belong to cerebellum and which no dot
%              voxel_sizes = a vector describing the voxel sizes in x, y
%                            and z directions.
%
% Output: new_ref_mask = the corrected (shrinked) cerebellum

% Tomi Karjalainen, 11.5.2017

new_ref_mask = old_ref_mask;

xv = voxel_sizes(1);
yv = voxel_sizes(2);
zv = voxel_sizes(3);

hx = floor(16/xv);
hz = floor(10/zv);
hy = floor(16/yv);

i = 0;
for z = 1:size(old_ref_mask,3)
    slice = old_ref_mask(:,:,z);
    if(sum(slice(:)))
        i = i + 1;
        z_list(i) = z;
        % For each x-segment in the slice, remove the center
        for y = 1:size(slice,2)
            seg = slice(:,y);
            if(sum(seg))
                xidx = find(seg);
                xmean = floor(mean(xidx));
                seg(xmean-hx:xmean+hx) = 0;
                slice(:,y) = seg;
            end
        end
        [~,y_list] = find(slice);
        if(length(y_list) > 8)
            max_y = max(y_list);
            slice(:,max_y-hy:end) = 0;
        end
        new_ref_mask(:,:,z) = slice;
    end
end

idx = [z_list(1:hz) z_list(end-2*hz:end)];
new_ref_mask(:,:,idx) = 0;

end