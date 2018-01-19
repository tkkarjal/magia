function magia_write_githash(subject,githash)

data_path = getenv('DATA_DIR');
d = sprintf('%s/%s',data_path,subject);
if(exist(d,'dir'))
    githash_file = sprintf('%s/githash_%s.txt',d,subject);
    fid = fopen(githash_file,'w');
    fwrite(fid,githash);
    fclose(fid);
else
    error('Could not write githash for %s because the subject directory does not exist.',subject);
end

end