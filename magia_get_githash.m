function githash = magia_get_githash()

magia_path = getenv('MAGIA_PATH');

githashfile = [magia_path '/.git/refs/heads/master'];
if(exist(githashfile,'file'))
  fid = fopen(githashfile,'r');
  githash = fgetl(fid);
  fclose(fid);
else
  fprintf('Could not find the git hash file. Please download Magia using via command line using the command git clone https://github.com/tkkarjal/magia.git.);
  githash = 'Not available';
end

end
