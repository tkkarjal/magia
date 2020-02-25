function corrected_mask = magia_roi_correction(original_mask,meanpet_image)
% Anatomical correction of a ROI mask. The correction makes the radioactivity concentration within the ROI more homogenous.
% The correction is performed by clustering the radioactivity signal within the ROI into three clusters. The voxels in the
% cluster whose mean radioactivity concentration is lowest are excluded from the mask. This is very useful when the ROI mask
% extends outside brain tissue, as happens often when using automated methods (e.g. atlases or FreeSurfer). In these cases,
% the excluded voxels are typically the ones outside brain tissue (e.g. inside ventricles).

if(ischar(original_mask))
    V = spm_vol(original_mask);
    original_mask = spm_read_vols(V);
end
if(ischar(meanpet_image))
    V = spm_vol(meanpet_image);
    meanpet_image = spm_read_vols(V);
end

num_clusters = 3;

original_mask = original_mask > 0;
roi_idx = find(original_mask);
X = meanpet_image(roi_idx);

try
    Z = linkage(X,'ward','euclidean');
catch
    Z = linkage(X,'ward','euclidean','savememory','on');
end
c = cluster(Z,'maxclust',num_clusters);

cluster_mean_signals = zeros(num_clusters,1);
idx = cell(num_clusters,1);
for j = 1:num_clusters
    idx{j} = roi_idx(c == j);
    cluster_mean_signals(j) = mean(meanpet_image(idx{j}));
end

[~,min_idx] = min(cluster_mean_signals);
corrected_mask = zeros(size(meanpet_image));
idx(min_idx) = [];
for j = 1:num_clusters-1
    corrected_mask(idx{j}) = 1;
end

end
