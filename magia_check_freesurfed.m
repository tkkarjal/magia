function freesurfed = magia_check_freesurfed(mri_code)

fs_dir = getenv('FS_FINAL_DIR');
sub_dir = sprintf('%s/%s',fs_dir,mri_code);
if(~exist(sub_dir,'dir'))
    freesurfed = 0;
else
    error_file = sprintf('%s/scripts/recon-all.error',sub_dir);
    if(exist(error_file,'file'))
        freesurfed = -1;
    else
        done_file = sprintf('%s/scripts/recon-all.done',sub_dir);
        if(exist(done_file,'file'))
            freesurfed = 1;
        else
            freesurfed = 0;
        end
    end
end

end
