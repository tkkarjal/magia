function new_img = metpet_fill_brain_img(old_img)

new_img = old_img;
for y = 1:size(old_img,2)
    new_img(:,y,:) = metpet_fill_slice(old_img(:,y,:),'coronal');
end
for x = 1:size(old_img,1)
    new_img(x,:,:) = metpet_fill_slice(new_img(x,:,:),'sagittal');
end

end