function found = magia_check_found(image_id)

data_path = getenv('DATA_DIR');
sub_dir = sprintf('%s/%s',data_path,image_id);
if(~exist(sub_dir,'dir'))
    found = 0;
else
    pet_dir = sprintf('%s/PET',sub_dir);
    dcm_dir = sprintf('%s/dcm',pet_dir);
    if(~exist(dcm_dir,'dir'))
        ecat_dir = sprintf('%s/ecat',pet_dir);
        if(~exist(ecat_dir,'dir'))
            found = 0;
        else
            f = get_filenames(ecat_dir,'*.v');
            if(isempty(f))
                f = get_filenames(ecat_dir,'*.img');
                if(isempty(f))
                    found = 0;
                else
                    found = 1;
                end
            else
                found = 1;
            end
        end
    else
        f = get_filenames(dcm_dir,'*.dcm');
        if(isempty(f))
            found = 0;
        else
            found = 1;
        end
    end
end

end