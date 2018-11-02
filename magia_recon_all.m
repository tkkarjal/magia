function [seg_file,full_file,bet_file] = magia_recon_all(subject,mri_code)

freesurfed = magia_check_freesurfed(mri_code);

main_mri_dir = getenv('MRI_DIR');
main_data_dir = getenv('DATA_DIR');

sub_mri_dir = sprintf('%s/%s/T1',main_mri_dir,mri_code);
processed_mri_dir = sprintf('%s/%s/MRI',main_data_dir,subject);

temp_freesurfer_dir = getenv('FS_TEMP_DIR');
final_freesurfer_dir = getenv('FS_FINAL_DIR');

temp_freesurfer_sub_dir = sprintf('%s/%s',temp_freesurfer_dir,mri_code);
final_freesurfer_sub_dir = sprintf('%s/%s',final_freesurfer_dir,mri_code);

if(freesurfed)
    fprintf('recon-all already run for %s, no need to run the process again.\n',subject);
else
    cmd = sprintf('gunzip -r %s',sub_mri_dir);
    system(cmd);
    setenv('SUBJECTS_DIR',temp_freesurfer_dir);
    cmd = sprintf('source $FREESURFER_HOME/SetUpFreeSurfer.sh');
    system(cmd);
    if(~exist(temp_freesurfer_dir,'dir'))
        cmd = sprintf('mkdir %s',temp_freesurfer_dir);
        system(cmd);
    end
    if(exist(temp_freesurfer_sub_dir,'dir'))
        % if not freesurfed but the temp folder exists, the process was
        % interrupted and should be restarted
        rmdir(temp_freesurfer_sub_dir,'s');
    end
    
    % Find MRI
    ff = get_filenames(sub_mri_dir,'*.dcm');
    if(isempty(ff))
        ff = get_filenames(sub_mri_dir,'*.nii');
        if(isempty(ff))
            ff = get_filenames(sub_mri_dir,'*.img');
            if(isempty(ff))
                ff = get_filenames(sub_mri_dir,'*.v');
                if(isempty(ff))
                    error('Could not find MRI %s.\n',mri_code);
                end
            end
        end
    end
    sub_mri_file = ff{1};
    
    [~,name,ext] = fileparts(sub_mri_file);
    if(~strcmpi(ext,'.dcm') && ~strcmpi(ext,'.nii'))
        convert_to_nifti(sub_mri_dir,sub_mri_dir,name);
        sub_mri_file = sprintf('%s/%s.nii',sub_mri_dir,name);
        center_image(sub_mri_file);
    end
    cmd = sprintf('recon-all -s %s -i %s -all -cw256 -brainstem-structures -parallel',mri_code,sub_mri_file);
    system(cmd);
    cmd = sprintf('gzip -r %s',sub_mri_dir);
    system(cmd);
    cmd = sprintf('rm -rf %s',final_freesurfer_sub_dir);
    system(cmd);
    cmd = sprintf('cp -r %s %s',temp_freesurfer_sub_dir,final_freesurfer_dir);
    system(cmd);
    freesurfed = magia_check_freesurfed(mri_code);
    if(freesurfed)
        cmd = sprintf('rm -r %s',temp_freesurfer_sub_dir);
        system(cmd);
    else
        error('recon-all (FreeSurfer) failed for MRI id %s',mri_code);
    end
end

if(~exist(processed_mri_dir,'dir'))
    mkdir(processed_mri_dir);
end
% Skull-stripped brain
bet_file = sprintf('%s/mri_%s_bet.nii',processed_mri_dir,subject);
if(~exist(bet_file,'file'))
    cmd = sprintf('mri_convert --out_orientation RAS %s/mri/brain.mgz %s',...
        final_freesurfer_sub_dir,bet_file);
    system(cmd);
end
full_file = sprintf('%s/mri_%s_full.nii',processed_mri_dir,subject);
if(~exist(full_file,'file'))
    cmd = sprintf('mri_convert --out_orientation RAS %s/mri/orig.mgz %s',...
        final_freesurfer_sub_dir,full_file);
    system(cmd);
end
% Segmentation labels
seg_file = sprintf('%s/seg_%s.nii',processed_mri_dir,subject);
if(~exist(seg_file,'file'))
    cmd = sprintf('mri_convert --out_orientation RAS -rt nearest %s/mri/aparc+aseg.mgz %s',...
        final_freesurfer_sub_dir,seg_file);
    system(cmd);
end
bs_fs_file = sprintf('%s/mri/brainstemSsLabels.v10.FSvoxelSpace.mgz',final_freesurfer_sub_dir);
if(exist(bs_fs_file,'file'))
    magia_combine_seg_and_bs(seg_file,bs_fs_file);
end
