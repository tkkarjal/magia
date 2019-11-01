function GU = magia_convert_ki_to_gu(ki,gluc)

LC=0.65; %Lumped constant FDG in Brain
density=1.04; %Brain tissue density

GU = (100.*ki.*gluc)./(LC*density);

end
