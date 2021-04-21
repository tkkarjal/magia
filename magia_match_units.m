function corrected_input = magia_match_units(input,pet)

if(ischar(pet))
    V = spm_vol(pet);
    pet = spm_read_vols(V);
    clear V;
end
max_pet = max(pet(:));
max_input = max(input(:,2));

corrected_input = input;

if(max_pet > 200 && max_input < 200)
    % pet bq, input kbq
    corrected_input(:,2) = input(:,2)*1000;
elseif(max_pet < 200 && max_input > 200)
    % pet kbq, input bq
    corrected_input(:,2) = input(:,2)*0.001;
end

end
