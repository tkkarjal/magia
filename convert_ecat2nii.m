function convert_ecat2nii(ecat_file,nii_file)

[source_path, ecat_name, ecat_ext] = fileparts(ecat_file);
[destination_path, ~, nii_ext] = fileparts(nii_file);

% The ECAT files are badly oriented, so first rotate them to correct
% orientation
flipped_fname = fullfile(source_path,[ecat_name '_flipped' ecat_ext]);
cmd = sprintf('imgflip -x -y -z %s %s',ecat_file,flipped_fname);
system(cmd);

% Then convert to nii
cmd = sprintf('ecat2nii -O=%s %s',destination_path,flipped_fname);
system(cmd);

% remove the flipped file
cmd = sprintf('rm %s',flipped_fname);
system(cmd);

% Rename
nii_fname = fullfile(destination_path,[ecat_name '_flipped' nii_ext]);
cmd = sprintf('mv %s %s',nii_fname,nii_file);
system(cmd);

% The header is wrongly written, fix this
nii = load_nii(nii_file);
save_nii(nii,nii_file);

warning('The left and right sides may be reversed in the final nii file %s.\n',nii_file);
end