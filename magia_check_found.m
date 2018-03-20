function found = magia_check_found(image_id)

data_path = getenv('DATA_DIR');
sub_dir = sprintf('%s/%s',data_path,image_id);
if(~exist(sub_dir,'dir'))
    found = 0;
    return;
else
    pet_dir = sprintf('%s/PET',sub_dir);
    nii_dir = sprintf('%s/nii',pet_dir);
    dcm_dir = sprintf('%s/dcm',pet_dir);
    ecat_dir = sprintf('%s/ecat',pet_dir);
    if(exist(nii_dir,'dir'))
        f = get_filenames(nii_dir,'*.nii');
        if(~isempty(f))
            found = 1;
            return;
        end
    end
    if(exist(dcm_dir,'dir'))
        f = get_filenames(dcm_dir,'*.dcm');
        if(~isempty(f))
            found = 1;
            return;
        end
    end
    if(exist(ecat_dir,'dir'))
        f = get_filenames(ecat_dir,'*.img');
        if(~isempty(f))
            found = 1;
            return;
        else
            f = get_filenames(ecat_dir,'*.v');
            if(~isempty(f))
                found = 1;
                return;
            else
                found = 0;
            end
        end
    else
        found = 0;
    end
end

end