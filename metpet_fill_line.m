function newLine = metpet_fill_line(oldLine)

newLine = oldLine;

idx = find(oldLine);
if(length(idx)>1)
    newLine(idx(1):idx(end)) = 1;
end

end