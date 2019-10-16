function new_filenames = remove_first_characters(filenames,nchar)

[p,n] = cellfun(@fileparts,filenames,'UniformOutput',false);

for i = 1:size(n,1)
    nn = n{i};
    n{i} = nn((nchar+1):end);
end

new_filenames = strcat(p,'/',n,'.nii');

cellfun(@delete,new_filenames);

for i = 1:size(n,1)
    movefile(filenames{i},new_filenames{i},'f');
end

end