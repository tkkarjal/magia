function [files_fullpath,files_short] = get_filenames(directory,filter)

if(nargin < 2)
    msg = sprintf('You need to specify two input arguments: First, the directory under which you want to perform the search, and second the filter.\n\nFor example: files = get_filenames(''/scratch/shared/toolbox/spm12'',''*.m'')');
    error(msg);
end

d = dir(sprintf('%s/%s*',directory,filter));
N = length(d);
files_fullpath = cell(N,1);
files_short = cell(N,1);
i = 0;
for im = 1:N
    if(~(strcmp(d(im).name,'.') || strcmp(d(im).name,'..')) || strcmp(d(im).name,'.DS_Store'))
        i = i + 1;
        files_short{i,1} = d(im).name;
        files_fullpath{i,1} = sprintf('%s/%s',directory,d(im).name);
    end
end

empty_idx = cellfun(@isempty,files_short);
files_short(empty_idx) = [];
files_fullpath(empty_idx) = [];

% if(i==1)
%     files_fullpath = files_fullpath{1};
%     files_short = files_short{1};
% end

end