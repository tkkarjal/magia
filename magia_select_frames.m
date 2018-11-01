function pet_file = magia_select_frames(pet_file,num_frames)

V = spm_vol(pet_file);
N = length(V);
if(N > num_frames)
    % split the 4d nifti into a series of 3d niftis
    p = fileparts(pet_file);
    static_niftis = spm_split_nifti(pet_file,p);
    delete(pet_file);
    % delete the last N - num_frames frames
    delf = static_niftis(num_frames+1:N);
    cellfun(@delete,delf);
    static_niftis = static_niftis(1:num_frames);
    % remerge the remaining 3d niftis
    spm_nifti_dynamize(static_niftis,pet_file);
else
    warning('%s already has at least %.0f frames, did not remove any\n',pet_file,num_frames);
end

end