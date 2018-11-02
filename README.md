# magia
Brain PET analysis pipeline

Automatic analysis pipeline.

## Running pipeline locally

A number of environment variables need to be set to run locally, 
so replace /dir/ with the appropriate path:

setenv('DATA_DIR','/dir/magia_data'); %% main path for data

setenv('MRI_DIR','/dir/magia_data/MRI'); %% path for MRI data

setenv('MAGIA_PATH', '/dir/magia'); %% path for magia scripts

setenv('MAGIA_ARCHIVE', '/dir/magia_data/archive'); %% path to store files, empty directory

setenv('FS_TEMP_DIR', '/dir/magia_data/FreeSurfer_temp') %% path to temp store FS files

setenv('FS_FINAL_DIR', '/dir/magia_data/FreeSurfer') %% path to save FS files

setenv('ARCHIVE_DIR', '/dir/magia_data/archive') %% as above

setenv('SPM_DIR', '/dir/SPM') %% local SPM directory

A possible directory structure, and note specific format of file names:

{DATA_DIR}/subj1/PET/nii/pet_subj1.nii

{MRI_DIR}/subj1/T1/ (dicom files)
