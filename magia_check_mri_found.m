function mri_found = magia_check_mri_found(mri_id)

main_mri_dir = getenv('MRI_DIR');
d = sprintf('%s/%s/T1',main_mri_dir,mri_id);
if(exist(d,'dir'))
    f = get_filenames(d,'*.dcm');
    if(isempty(f))
        f = get_filenames(d,'*.img');
        if(isempty(f))
            f = get_filenames(d,'*.v');
            if(isempty(f))
                mri_found = 0;
            else
                mri_found = 1;
            end
        else
            mri_found = 1;
        end
    else
        mri_found = 1;
    end
else
    dd = sprintf('%s/%s',main_mri_dir,mri_id);
    if(exist(dd,'dir'))
        f = get_filenames(dd,'*.dcm');
        if(~isempty(f))
            mkdir(d);
            M = length(f);
            for i = 1:M
                movefile(f{i},d);
            end
            mri_found = 1;
        else
            mri_found = 0;
        end
    else
        mri_found = 0;
    end
end

end