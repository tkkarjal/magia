function [gu_img_file,gu_img] = magia_convert_ki_to_gu_img(ki_img_file,gluc)

V = spm_vol(ki_img_file);
ki_img = spm_read_vols(V);

gu_img = magia_convert_ki_to_gu(ki_img,gluc);

if(isempty(V.descrip))
    V.descrip = sprintf('gluc: %f',gluc);
else
    V.descrip = sprintf('%s / gluc: %f',V.descrip,gluc);
end

[p,n] = fileparts(V.fname);

gu_img_file = sprintf('%s/%s_gu.nii',p,n);
V.fname = gu_img_file;
spm_write_vol(V,gu_img);

end