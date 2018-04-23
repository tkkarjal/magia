function magia_processor(subject,I,modeling_options)
%% The main workhorse of the MAGIA pipeline.
% Processes a brain PET study with standardized methods. The processing
% method depends on the tracer, whether the study is dynamic or static,
% whether an MRI is available for FreeSurfing, and whether plasma input is
% available for modeling.

% The first input argument defines a subject id. The function assumes that
% a folder with exactly the same name exists under getenv('DATA_DIR').
% Please see the wiki page for information about the assumed folder
% structre.

megapet_dir = getenv('MEGAPET_HOME');
data_path = getenv('DATA_DIR');
D = sprintf('%s/%s',data_path,subject);
template_dir = sprintf('%s/templates',megapet_dir);
brainmask = '/scratch/shared/templates/brainmask.nii';

found = magia_check_found(subject);
if(~found)
    error('Could not find image files for %s. Please make sure the subject has its own folder under %s.',subject,data_path);
end

[I, modeling_options] = magia_check_metadata(subject, I, modeling_options);
tracer = I.tracer;
frames = I.frames;
use_mri = I.use_mri;
mri_code = I.mri;
plasma = I.plasma;
rc = I.rc;
dyn = I.dynamic;
dc = I.dc;
fwhm = I.fwhm;
weight = I.weight;
dose = I.dose;

model = modeling_options.model;
roi_set = modeling_options.roi_set;
magia_write_modeling_options2(subject,modeling_options);

roi_info = magia_get_roi_info(roi_set,tracer);

if(~plasma)
    ref_region = magia_get_ref_region(tracer);
end

magia_clean_files(subject);
githash = magia_get_githash();
magia_write_githash(subject,githash);

fprintf('Starting processing of %s...\n',subject);

pet_file = magia_get_pet_file(subject);

if(dyn)
    test_dyn = magia_test_dyn(subject);
    if(~test_dyn)
        error('Cannot magia %s. Reason: dynamic image assumed but only one frame found.',subject);
    end
end

no_frames = size(frames,1);
if(dyn && no_frames == 1)
    error('Cannot magia %s. Reason: Only one frame specified for a dynamic image.',subject);
elseif(~dyn && no_frames > 1)
    error('Cannot magia %s. Reason: Multiple frames specified for a static image.',subject);
end

if(~dc)
    decay_correct_to_injection_time(pet_file,frames,tracer);
end

results_dir = sprintf('%s/results',D);
if(~exist(results_dir,'dir'))
    mkdir(results_dir);
end

center_image2(pet_file,tracer); % the pet image should always be centered

if(dyn && use_mri && plasma)
    
    % (1) process dynamic images with mri and plasma data
    
    fprintf('%s: Dynamic images, MRI, plasma input\n',subject);
    
    [motion_corrected_pet,meanpet_file] = motion_correction(pet_file);
    motion_parameter_qc(subject);
    [mri_file,seg_file,bet_file] = process_mri(subject,mri_code);
    
    fprintf('%s: Coregistering MRI files to mean PET image...\n',subject);
    other_images = {seg_file;bet_file};
    spm_coregister_estimate(meanpet_file,mri_file,other_images);
    resampled_bet_file = spm_coregister_reslice(meanpet_file,bet_file,4);
    resampled_seg_file = spm_coregister_reslice(meanpet_file,seg_file,0);
    coreg_qc(subject,meanpet_file,resampled_bet_file);
    
    roi_masks = create_roi_masks2(resampled_seg_file,roi_info);
    tacs = calculate_roi_tacs(motion_corrected_pet,roi_masks);
    input = read_plasma(subject);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    brainmask = create_brainmask(subject,resampled_bet_file);
    parametric_images = calculate_parametric_images(motion_corrected_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
    deformation_field = spm_segment(mri_file);
    mri_histogram_qc(subject,mri_file);
    normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
    smooth_img(normalized_images(2:end),fwhm);
    
elseif(dyn && use_mri && ~plasma)
    
    % (2) process dynamic images with mri but without plasma data
    
    fprintf('%s: Dynamic images, MRI, reference tissue input\n',subject);
    
    [motion_corrected_pet,meanpet_file] = motion_correction(pet_file);
    motion_parameter_qc(subject);
    [mri_file,seg_file,bet_file] = process_mri(subject,mri_code);
    
    fprintf('%s: Coregistering MRI files to mean PET image...\n',subject);
    other_images = {seg_file;bet_file};
    spm_coregister_estimate(meanpet_file,mri_file,other_images);
    resampled_bet_file = spm_coregister_reslice(meanpet_file,bet_file,4);
    resampled_seg_file = spm_coregister_reslice(meanpet_file,seg_file,0);
    coreg_qc(subject,meanpet_file,resampled_bet_file);
    
    [roi_masks,ref_mask] = create_roi_masks2(resampled_seg_file,roi_info,ref_region);
    ref_mask = anatomical_reference_region_correction2(ref_mask,tracer,resampled_seg_file);
    % check_roi_normality(ref_mask,meanpet_file)
    [ref_mask,thr] = data_driven_reference_region_correction_fwhm(ref_mask,meanpet_file);
    
    if(rc)
        specific_binding_mask = create_specific_binding_mask(meanpet_file,thr);
        remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask);
    end
    
    tacs = calculate_roi_tacs(motion_corrected_pet,roi_masks);
    input = get_ref_tac(motion_corrected_pet,ref_mask);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    brainmask = create_brainmask(subject,resampled_bet_file);
    parametric_images = calculate_parametric_images(motion_corrected_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
    deformation_field = spm_segment(mri_file);
    mri_histogram_qc(subject,mri_file);
    normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
    smooth_img(normalized_images(2:end),fwhm);
    
elseif(dyn && ~use_mri && plasma)
    
    % (3) process dynamic images without mri but with plasma data
    
    fprintf('%s: Dynamic images, no MRI, plasma input\n',subject);
    
    [motion_corrected_pet,meanpet_file] = motion_correction(pet_file);
    motion_parameter_qc(subject);
    [~,normalized_pet] = normalize_using_template(meanpet_file,template_dir,tracer,motion_corrected_pet);
    roi_masks = get_roi_masks(roi_info.mask_dir);
    tacs = calculate_roi_tacs(normalized_pet,roi_masks);
    input = read_plasma(subject);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
    smooth_img(normalized_parametric_images,fwhm);
    
elseif(~dyn && use_mri && plasma)
    
    % (4) process static images with mri and plasma data
    
    fprintf('%s: Static image, MRI, plasma input\n',subject);
    
    [mri_file,seg_file,bet_file] = process_mri(subject,mri_code);
    
    fprintf('%s: Coregistering MRI files to mean PET image...\n',subject);
    other_images = {seg_file;bet_file};
    spm_coregister_estimate(pet_file,mri_file,other_images);
    resampled_bet_file = spm_coregister_reslice(pet_file,bet_file,4);
    resampled_seg_file = spm_coregister_reslice(pet_file,seg_file,0);
    coreg_qc(subject,pet_file,resampled_bet_file);
    
    roi_masks = create_roi_masks2(resampled_seg_file,roi_info);
    tacs = calculate_roi_tacs(pet_file,roi_masks);
    input = read_plasma(subject);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    brainmask = create_brainmask(subject,resampled_bet_file);
    parametric_images = calculate_parametric_images(pet_file,input,frames,modeling_options,results_dir,tracer,brainmask);
    deformation_field = spm_segment(mri_file);
    mri_histogram_qc(subject,mri_file);
    normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
    smooth_img(normalized_images(2:end,fwhm));
    
elseif(dyn && ~use_mri && ~plasma)
    
    % (5) process dynamic images without mri or plasma data
    
    fprintf('%s: Dynamic images, no MRI, reference tissue input\n',subject);
    
    [motion_corrected_pet,meanpet_file] = motion_correction(pet_file);
    motion_parameter_qc(subject);
    [normalized_meanpet,normalized_pet] = normalize_using_template(meanpet_file,template_dir,tracer,motion_corrected_pet);
    [roi_masks,ref_mask] = get_roi_masks(roi_info.mask_dir,ref_region.label);
    
    sub_mask_dir = sprintf('%s/%s/masks',data_path,subject);
    [ref_mask,thr] = data_driven_reference_region_correction_fwhm(ref_mask,normalized_meanpet,sub_mask_dir);
    if(rc)
        specific_binding_mask = create_specific_binding_mask(normalized_meanpet,thr);
        remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask,sub_mask_dir);
    end
    tacs = calculate_roi_tacs(normalized_pet,roi_masks);
    input = get_ref_tac(normalized_pet,ref_mask);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    brainmask = create_brainmask(subject,brainmask);
    normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
    smooth_img(normalized_parametric_images,fwhm);
    
elseif(~dyn && ~use_mri && plasma)
    
    % (6) process static images without mri but with plasma data
    
    fprintf('%s: Static image, no MRI, plasma input\n',subject);
    
    normalized_pet = normalize_using_template(pet_file,template_dir,tracer);
    input = read_plasma(subject);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
    smooth_img(normalized_parametric_images,fwhm);
    roi_masks = get_roi_masks(roi_info.mask_dir);
    tacs = calculate_roi_tacs(normalized_pet,roi_masks);
    
elseif(~dyn && use_mri && ~plasma)
    
    % (7) process static images with mri but without plasma data
    
    fprintf('%s: Static image, MRI, reference tissue input\n',subject);
    
    [mri_file,seg_file,bet_file] = process_mri(subject,mri_code);
    
    fprintf('%s: Coregistering MRI files to mean PET image...\n',subject);
    other_images = {seg_file;bet_file};
    spm_coregister_estimate(pet_file,mri_file,other_images);
    resampled_bet_file = spm_coregister_reslice(pet_file,bet_file,4);
    resampled_seg_file = spm_coregister_reslice(pet_file,seg_file,0);
    coreg_qc(subject,pet_file,resampled_bet_file);
    
    [roi_masks,ref_mask] = create_roi_masks2(resampled_seg_file,roi_info,ref_region);
    [ref_mask,thr] = data_driven_reference_region_correction_fwhm(ref_mask,pet_file);
    
    specific_binding_mask = create_specific_binding_mask(pet_file,thr);
    remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask);
    tacs = calculate_roi_tacs(pet_file,roi_masks);
    input = get_ref_tac(pet_file,ref_mask);
    magia_input_qc(subject,input,plasma,dose,weight,tracer,frames);
    brainmask = create_brainmask(subject,resampled_bet_file,specific_binding_mask);
    parametric_images = calculate_parametric_images(pet_file,input,frames,modeling_options,results_dir,tracer,brainmask);
    deformation_field = spm_segment(mri_file);
    mri_histogram_qc(subject,mri_file);
    normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
    smooth_img(normalized_images(2:end),fwhm);
    
else
    
    % (8) process static images without mri or plasma data
    
    fprintf('%s: Static image, no MRI, reference tissue input\n',subject);
    
    [roi_masks,ref_mask] = get_roi_masks(roi_info.mask_dir,ref_region.label);
    normalized_pet = normalize_using_template(pet_file,template_dir,tracer);
    
    sub_mask_dir = sprintf('%s/%s/masks',data_path,subject);
    [ref_mask,thr] = data_driven_reference_region_correction_fwhm(ref_mask,normalized_pet,sub_mask_dir);
    if(rc)
        specific_binding_mask = create_specific_binding_mask(normalized_pet,thr);
        remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask);
    end
    
    input = get_ref_tac(normalized_pet,ref_mask);
    input_qc(subject,input,frames);
    brainmask = create_brainmask(subject,brainmask);
    tacs = calculate_roi_tacs(normalized_pet,roi_masks);
    normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
    smooth_img(normalized_parametric_images,fwhm);
    
end

parametric_image_qc(subject,model,dyn);
fprintf('%s: Starting ROI level visualization and fitting\n ',subject);

visualize_tacs(tacs,input,frames,roi_info,results_dir);
T = roi_fitting(tacs,input,frames,modeling_options,roi_info,results_dir);
visualize_fits(T,tacs,input,frames,modeling_options,roi_info,results_dir);
roi_bars(T,modeling_options,results_dir);

end