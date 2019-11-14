function excluded_frames = magia_parse_excluded_frames(s)

sep_idx = regexp(s,'[ ,]');
n = length(sep_idx)+1;
excluded_frames = zeros(n,1);
k = 1;
for i = 1:n-1
    j = sep_idx(i);
    excluded_frames(i) = str2double(s(k:j-1));
    k = j + 1;
end
excluded_frames(n) = str2double(s(k:end));

end