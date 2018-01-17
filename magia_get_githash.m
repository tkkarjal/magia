function githash = magia_get_githash()

magia_path = getenv('MAGIA_PATH');

githashfile = [magia_path '/.git/refs/heads/master'];
fid = fopen(githashfile,'r');
githash = fgetl(fid);
fclose(fid);

end