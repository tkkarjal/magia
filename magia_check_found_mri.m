function found = magia_check_found_mri(mri_code)

mri_dir = sprintf('%s/%s/T1',getenv('MRI_DIR'),mri_code);
if(~exist(mri_dir,'dir'))
  found = 0;
else
  f = get_filenames(mri_dir,'*');
  if(isempty(f))
    found = 0;
  else
    found = 1;
  end
end

end
