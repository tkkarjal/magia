function freesurfed = magia_check_freesurfed(mri_code)

fs_dir = '~/vsshp.net/Research/Neurotiede/aivo/FreeSurfer';
sub_dir = sprintf('%s/%s',fs_dir,mri_code);
if(~exist(sub_dir,'dir'))
    freesurfed = 0;
else
    ready_file = sprintf('%s/scripts/recon-all.done',sub_dir);
    if(exist(ready_file,'file'))
        freesurfed = 1;
    else
        freesurfed = 0;
    end
end

end