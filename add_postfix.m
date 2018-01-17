function new_filename = add_postfix(filename,postfix)

if(ischar(filename))
    [p,n,e] = fileparts(filename);
    n = [n postfix];
    new_filename = fullfile(p,[n e]);
elseif(iscell(filename))
    new_filename = cell(size(filename));
    for i = 1:length(filename)
        new_filename{i} = add_postfix(filename{i},postfix);
    end
else
    error('filename must be either a string or a cell array.');
end

end