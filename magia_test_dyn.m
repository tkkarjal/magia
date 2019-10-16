function dyn = magia_test_dyn(image_file)

if(exist(image_file,'file'))
    V = spm_vol(image_file);
    img = spm_read_vols(V);
    no_frames = size(img,4);
    if(no_frames > 1)
        dyn = 1;
    else
        dyn = 0;
    end
else
    error('Could not find file %s.',image_file);
end

end