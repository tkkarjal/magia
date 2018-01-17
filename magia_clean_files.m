function magia_clean_files(subject)

data_path = getenv('DATA_DIR');
D = sprintf('%s/%s',data_path,subject);

if(exist(D,'dir'))
    fprintf('Deleting files (%s)...',subject);
    
    % Remove bad directories
    dir_names = {'MRI' 'masks' 'results'};
    for i = 1:length(dir_names)
        d = sprintf('%s/%s',D,dir_names{i});
        if(exist(d,'dir'))
            rmdir(d,'s');
        end
    end
    
    % Remove PET files
    pet_dir = sprintf('%s/PET',D);
    if(exist(pet_dir,'dir'))
        good_dirs = {
            sprintf('%s/dcm',pet_dir);
            sprintf('%s/ecat',pet_dir);
            sprintf('%s/nii',pet_dir);
            };
        f = setdiff(get_filenames(pet_dir,''),good_dirs);
        cellfun(@delete,f);
        fprintf(' Done.\n');
    else
        warning('Could not find PET files for %s.\n',subject);
    end
    
    plasma_dir = sprintf('%s/plasma',D);
    if(exist(plasma_dir,'dir'))
        f = get_filenames(plasma_dir,'*.png');
        if(~isempty(f))
            delete(f{1});
        end
    end
    
    % Delete the QC file
    
    qc_file = sprintf('%s/qc_%s.ps',D,subject);
    if(exist(qc_file,'file'))
        delete(qc_file);
    end
    
else
    aivo_set_info(subjects,'found',0);
    error('Could not find subject directory for %s.',subject);
end

end