function magia_convert_to_nifti(source_dir,nii_dir,filename)
% The function assumes that source_dir contains only either
% i) a bunch of dicom files
% ii) a single ecat file (either .v or .img)
% These files are then converted into a single (4D when applicable) nifti

[p,n,e] = fileparts(filename);
if(isempty(p))
    p = nii_dir;
end
if(isempty(e))
    e = '.nii';
end
filename = fullfile(p,[n e]);

cmd = sprintf('gunzip -rf %s',source_dir);
system(cmd);

f = get_filenames(source_dir,'*.dcm');
if(~isempty(f))
    nii_fnames = spm_dcm2nii_2(source_dir,nii_dir);
    if(length(nii_fnames)==1)
        movefile(nii_fnames{1},filename,'f');
    else
        reversed = magia_check_reversed(f{1});
        if(reversed)
            I = length(nii_fnames):-1:1;
            nii_fnames = nii_fnames(I);
        end
        spm_nifti_dynamize(nii_fnames,filename); % converts from 3d to 4d
    end
else
    f = get_filenames(source_dir,'*.v');
    if(isempty(f))
        f = get_filenames(source_dir,'*.img');
    end
    if(~isempty(f))
        [p,~,e] = fileparts(filename);
        h = fullfile(p,['temp' e]);
        convert_ecat2nii(f{1},h);
        spm_nifti_dynamize({h},filename);
        delete(h);
    else
        error('Could not find dcm or ecat files from %s.\n',source_dir);
    end
end

cmd = sprintf('gzip -r %s',source_dir);
system(cmd);

end
