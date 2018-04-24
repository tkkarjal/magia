function force_ras(filename)

cmd = sprintf('mri_convert --out_orientation RAS %s %s',filename,filename);
system(cmd);

end