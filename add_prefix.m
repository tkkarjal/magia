function new_filename = add_prefix(filename,prefix)

if(ischar(filename))
    [p,n,e] = fileparts(filename);
    n = [prefix n];
    new_filename = fullfile(p,[n e]);
elseif(iscell(filename))
    new_filename = cell(size(filename));
    for i = 1:length(filename)
        new_filename{i} = add_prefix(filename{i},prefix);
    end
else
    error('filename must be either a string or a cell array.');
end

end