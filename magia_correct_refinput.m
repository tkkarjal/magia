function input = magia_correct_refinput(input,frames)
% Sometimes the first frame is bad, resulting in NaNs in the first frame
% after motion-correction. This function uses interpolation to fix the
% issue.

if(isnan(input(1)))
    t = mean(frames,2);
    input(1) = interp1([0 t(2)],[0 input(2)],'linear');
end

end