function frames = parse_frames_string(frame_string)

F = strsplit(frame_string,';');
frames = zeros(length(F),2);
for i = 1:length(F)
    ff = strsplit(F{i},' ');
    frames(i,1) = str2double(ff{1});
    frames(i,2) = str2double(ff{2});
end

end