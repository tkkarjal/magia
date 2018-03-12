function reversed = magia_check_reversed(dicom_file)

fname = '~/magia_temp.txt';
cmd = sprintf('cat %s > %s',dicom_file,fname);
system(cmd);

fid = fopen(fname,'r');
txt = fread(fid,'*char');
fclose(fid);

if(size(txt,1) > 1)
    txt = txt';
end

idx = regexp(txt,'Ingenuity','once');

if(isempty(idx))
    reversed = 0;
else
    reversed = 1;
end

end