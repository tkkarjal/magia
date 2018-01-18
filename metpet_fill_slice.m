function newSlice = metpet_fill_slice(oldSlice,plane)

newSlice = oldSlice;

switch plane
    case 'coronal'
        for x = 1:size(oldSlice,1)
            oldLine = oldSlice(x,1,:);
            newSlice(x,1,:) = metpet_fill_line(oldLine);
        end
    case 'sagittal'
        for y = 1:size(oldSlice,2)
            oldLine = oldSlice(1,y,:);
            newSlice(1,y,:) = metpet_fill_line(oldLine);
        end
end
end