function magia_fix_first_frame(pet_file,frames)
% The first frames of PET data looks bad sometimes. Often this is not a
% problem, because the radioactivity measured with PET increases linearly
% in the beginning.
% At t = 0, the radioactivity concentration C is known to
% be zero: C(0) = 0. 
% C(t1) is unknown
% C(t2) is however often known, and thus C(t1) can be interpolated because
% C(0) and C(t2) are known, and C is supposed to increalse linearly in the
% beginning.

%% Read data

V = spm_vol(pet_file);
img = spm_read_vols(V);
t = mean(frames,2);

%% Plot number of zero-voxels

nframes = size(frames,1);
nzeros = zeros(nframes,1);

for i = 1:nframes
    h = squeeze(img(:,:,:,i));
    nzeros(i) = sum(h(:),'omitnan');
end

figure(); plot(nzeros);
xlabel('Frame #'); ylabel('Number of voxels with zero intensity');
title(pet_file);

%% Execute correction

answer = questdlg('Are you sure you want to replace the first frame with interpolated data?','First-frame fix','Yes','No','No');

if(strcmp(answer,'Yes'))
    img1 = img(:,:,:,1);
    img2 = img(:,:,:,2);
    
    mask = img2 > 0;
    
    v2 = img2(mask);
    y = [zeros(size(v2)) v2];
    v1 = interp1([0 t(2)],y',t(1),'linear');
    
    img1(mask) = v1;
    img(:,:,:,1) = img1;
    
    spm_write_4d_nifti(V,img,pet_file);
end

end