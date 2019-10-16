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
    
    % Delete the modeling options file
    mo_file = sprintf('%s/modeling_options_%s.txt',D,subject);
    if(exist(mo_file,'file'))
        delete(mo_file);
    end
    
    % Delete the githash file
    gh_file = sprintf('%s/githash_%s.txt',D,subject);
    if(exist(gh_file,'file'))
        delete(gh_file);
    end
    
    % Delete the specs file
    specs_file = sprintf('%s/specs_%s.txt',D,subject);
    if(exist(specs_file,'file'))
        delete(specs_file);
    end
    
else
    error('Could not find the subject directory for %s.',subject);
end

end