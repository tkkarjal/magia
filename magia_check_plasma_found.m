function plasma_found = magia_check_plasma_found(subject)

data_path = getenv('DATA_DIR');
plasma_dir = sprintf('%s/%s/plasma',data_path,subject);
if(~exist(plasma_dir,'dir'))
    plasma_found = 0;
else
    f = get_filenames(plasma_dir,'');
    if(isempty(f))
        plasma_found = 0;
    else
        plasma_found = 1;
    end
end

end