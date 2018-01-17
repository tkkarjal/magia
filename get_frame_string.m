function frame_string = get_frame_string(frames)

N = size(frames,1);
for i = 1:N
    if(i==1)
        frame_string = [num2str(frames(i,1)) ' ' num2str(frames(i,2))];
    else
        frame_string = [frame_string ';' num2str(frames(i,1)) ' ' num2str(frames(i,2))];
    end
end

end