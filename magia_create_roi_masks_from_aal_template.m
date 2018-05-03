function magia_create_roi_masks_from_aal_template(aal_template,outdir)

roi_names = {
    'Precentral';
    'Frontal_Sup'
    'Frontal_Sup_Orb'
    'Frontal_Mid'
    'Frontal_Mid_Orb'
    'Frontal_Inf_Oper'
    'Frontal_Inf_Tri'
    'Frontal_Inf_Orb'
    'Rolandic_Oper'
    'Supp_Motor_Area'
    'Olfactory'
    'Frontal_Sup_Medial'
    'Frontal_Med_Orb'
    'Rectus'
    'Insula'
    'Cingulum_Ant'
    'Cingulum_Mid'
    'Cingulum_Post'
    'Hippocampus'
    'ParaHippocampal'
    'Amygdala'
    'Calcarine'
    'Cuneus'
    'Lingual'
    'Occipital_Sup'
    'Occipital_Mid'
    'Occipital_Inf'
    'Fusiform'
    'Postcentral'
    'Parietal_Sup'
    'Parietal_Inf'
    'SupraMarginal'
    'Angular'
    'Precuneus'
    'Paracentral_Lobule'
    'Caudate'
    'Putamen'
    'Pallidum'
    'Thalamus'
    'Heschl'
    'Temporal_Sup'
    'Temporal_Pole_Sup'
    'Temporal_Mid'
    'Temporal_Pole_Mid'
    'Temporal_Inf'
    'Cerebelum_Crus1'
    'Cerebelum_Crus2'
    'Cerebelum_3'
    'Cerebelum_4_5'
    'Cerebelum_6'
    'Cerebelum_7b'
    'Cerebelum_8'
    'Cerebelum_9'
    'Cerebelum_10'
};


V = spm_vol(aal_template);
img = spm_read_vols(V);

if(~exist(outdir,'dir'))
    mkdir(outdir);
end

V.dt = [spm_type('uint8') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';

for i = 1:54
    labels = [2*i-1 2*i];
    mask = uint8(ismember(img,labels));
    roi = lower(roi_names{i});
    V.fname = sprintf('%s/%s.nii',outdir,roi);
    spm_write_vol(V,mask);
end

end