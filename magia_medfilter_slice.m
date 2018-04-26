function new_slice = magia_medfilter_slice(old_slice)

old_slice = squeeze(old_slice);
new_slice = old_slice;

for x = 1:size(new_slice,1)
    old_line = old_slice(x,:);
    new_line = medfilt1(old_line,3);
    new_slice(x,:) = new_line;
end

end