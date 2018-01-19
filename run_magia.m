function run_magia(subject)

addpath /home/glereane/code/bramila/external/ISC_toolbox/niftitools

megapet_dir = getenv('MEGAPET_HOME');
data_path = getenv('DATA_DIR');
D = sprintf('%s/%s',data_path,subject);
mask_dir = sprintf('%s/masks',megapet_dir);
template_dir = sprintf('%s/templates',megapet_dir);
brainmask = '/scratch/shared/templates/brainmask.nii';

try
    found = magia_check_found(subject);
    aivo_set_info(subject,'found',found);
    if(~found)
        error('Could not proceed with %s because some input data were missing.',subject);
    end
    
    magia_clean_files(subject);
    
    % Read info
    
    tracer = aivo_get_info(subject,'tracer');
    if(~isempty(tracer))
        tracer = tracer{1};
    else
        error('Tracer has not been specified for %s in AIVO.',subject);
    end
    
    fs = aivo_get_info(subject,'frames');
    if(~isempty(fs))
        fs = fs{1};
        frames = parse_frames_string(fs);
        if(frames(1,2) - frames(1,1) >= 30)
            frames = frames/60;
            fs = get_frame_string(frames);
            aivo_set_info(subject,'frames',fs);
        end
    else
        error('Frames have not been specified for %s in AIVO.',subject);
    end
    
    mri = aivo_get_info(subject,'use_mri');
    if(mri)
        mri_code = aivo_get_info(subject,'mri');
        if(~isempty(mri_code))
            mri_code = mri_code{1};
        end
        if(strcmp(mri_code,'0'))
            mri = 0;
        end
    end
    
    if(mri)
        mri_found = magia_check_mri_found(mri_code);
        if(~mri_found)
            error('Cannot magia PET study %s because the MRI (%s) that was specified was not found.',subject,mri_code);
        end
    end
    
    if(mri)
        freesurfed = magia_check_freesurfed(mri_code);
        aivo_set_info(subject,'freesurfed',freesurfed);
    end
    
    plasma = aivo_get_info(subject,'plasma');
    if(iscell(plasma))
        plasma = plasma{1};
    end
    if(plasma)
        plasma_found = magia_check_plasma_found(subject);
        if(~plasma_found)
            error('Cannot magia the PET study %s because the plasma file could not be found.',subject);
        end
    end
    
    rc = aivo_get_info(subject,'rc');
    if(iscell(rc))
        rc = rc{1};
    end
    if(isnan(rc))
        rc = 1;
        aivo_set_info(subject,'rc',1);
    end
    if(rc==-1)
        rc = 1;
    end
    
    dyn = aivo_get_info(subject,'dynamic');
    if(iscell(dyn))
        dyn = dyn{1};
    end
    
    if(isnan(dyn))
        if(size(frames,1) > 1)
            dyn = 1;
        else
            dyn = 0;
        end
        aivo_set_info(subject,'dynamic',dyn);
    end
    
    pet_dir = sprintf('%s/PET',D);
    
    modeling_options = aivo_read_modeling_options(subject);
    model = modeling_options.model;
    roi_set = modeling_options.roi_set;
    if(strcmp(roi_set,'tracer_default') && ~mri)
        roi_set = 'atlas';
        modeling_options.roi_set = roi_set;
    end
    magia_write_modeling_options2(subject,modeling_options);
    
    if(strcmpi(roi_set,'tracer_default'))
        roi_info = get_tracer_default_roi_set(tracer);
    elseif(strcmpi(roi_set,'atlas'))
        roi_info = get_atlas_rois(mask_dir);
    elseif(strcmpi(roi_set,'[18f]fdg_atlas'))
        mask_dir = sprintf('%s/fdg_rois',megapet_dir);
        roi_info = get_atlas_rois(mask_dir);
    else
        roi_info = read_roi_info(roi_set);
    end
    
    if(strcmpi(model,'srtm') || strcmpi(model,'auc_ratio') || strcmpi(model,'patlak_ref'))
        switch tracer
            case {'[11c]carfentanil' '[18f]dopa'}
                ref_region.label = 'OC';
                ref_region.codes = [1011 2011];
            case {'[11c]raclopride','[11c]madam','[18f]spa-rq','[11c]pib','[11c]pbr28','[18f]cft'}
                ref_region.label = 'CER';
                ref_region.codes = [8 47];
        end
    end
    
    fprintf('Starting processing of %s...\n',subject);
    
    raw_pet_file_gz = sprintf('%s/nii/pet_%s.nii.gz',pet_dir,subject);
    if(exist(raw_pet_file_gz,'file'))
        cmd = sprintf('gunzip %s',raw_pet_file_gz);
        system(cmd);
    end
    raw_pet_file = sprintf('%s/nii/pet_%s.nii',pet_dir,subject);
    pet_file = sprintf('%s/pet_%s.nii',pet_dir,subject); % 4D NIFTI
    if(exist(raw_pet_file,'file'))
        copyfile(raw_pet_file,pet_file,'f');
        cmd = sprintf('gzip %s',raw_pet_file);
        system(cmd);
    else
        dcm_dir = sprintf('%s/dcm',pet_dir);
        ecat_dir = sprintf('%s/ecat',pet_dir);
        if(exist(dcm_dir,'dir'))
            source_dir = dcm_dir;
        elseif(exist(ecat_dir,'dir'))
            source_dir = ecat_dir;
        else
            error('Could not find raw PET data (dcm or ecat) from %s.',pet_dir);
        end
        convert_to_nifti(source_dir,pet_dir,pet_file,cellstr(aivo_get_info(subject,'scanner')));
    end
    
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
    
    dc = aivo_get_info(subject,'dc');
    if(iscell(dc))
        dc = dc{1};
    end
    if(isnan(dc) || dc == -1)
        error('Cannot magia %s because it was not specified if the data have already been decay-corrected or not.',subject);
    end
        
    if(~dc)
        decay_correct_to_injection_time(pet_file,frames,tracer);
    end
    
    fwhm = aivo_get_info(subject,'fwhm');
    if(iscell(fwhm))
        fwhm = fwhm{1};
    end
    if(isnan(fwhm))
        fwhm = 8;
        aivo_set_info(subject,'fwhm',fwhm);
    end
    
    results_dir = sprintf('%s/results',D);
    if(~exist(results_dir,'dir'))
        mkdir(results_dir);
    end
    
    % Start processing
    
    center_image2(pet_file,tracer); % the pet image should always be centered
    
    if(dyn && mri && plasma)
        
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
        brainmask = create_brainmask(subject,resampled_bet_file);
        parametric_images = calculate_parametric_images(motion_corrected_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
        deformation_field = spm_segment(mri_file);
        mri_histogram_qc(subject,mri_file);
        normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
        smooth_img(normalized_images(2:end),fwhm);
        
    elseif(dyn && mri && ~plasma)
        
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
        
        specific_binding_mask = create_specific_binding_mask(meanpet_file,thr);
        if(rc)
            remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask);
        end
        
        tacs = calculate_roi_tacs(motion_corrected_pet,roi_masks);
        input = get_ref_tac(motion_corrected_pet,ref_mask);
        input_qc(subject,input,frames);
        brainmask = create_brainmask(subject,resampled_bet_file,specific_binding_mask);
        parametric_images = calculate_parametric_images(motion_corrected_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
        deformation_field = spm_segment(mri_file);
        mri_histogram_qc(subject,mri_file);
        normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
        smooth_img(normalized_images(2:end),fwhm);
        
    elseif(dyn && ~mri && plasma)
        
        % (3) process dynamic images without mri but with plasma data
        
        fprintf('%s: Dynamic images, no MRI, plasma input\n',subject);
        
        [motion_corrected_pet,meanpet_file] = motion_correction(pet_file);
        motion_parameter_qc(subject);
        [~,normalized_pet] = normalize_using_template(meanpet_file,template_dir,tracer,motion_corrected_pet);
        roi_masks = get_roi_masks(mask_dir);
        tacs = calculate_roi_tacs(normalized_pet,roi_masks);
        input = read_plasma(subject);
        normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
        smooth_img(normalized_parametric_images,fwhm);
        
    elseif(~dyn && mri && plasma)
        
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
        brainmask = create_brainmask(subject,resampled_bet_file);
        parametric_images = calculate_parametric_images(pet_file,input,frames,modeling_options,results_dir,tracer,brainmask);
        deformation_field = spm_segment(mri_file);
        mri_histogram_qc(subject,mri_file);
        normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
        smooth_img(normalized_images(2:end,fwhm));
        
    elseif(dyn && ~mri && ~plasma)
        
        % (5) process dynamic images without mri or plasma data
        
        fprintf('%s: Dynamic images, no MRI, reference tissue input\n',subject);
        
        [motion_corrected_pet,meanpet_file] = motion_correction(pet_file);
        motion_parameter_qc(subject);
        [normalized_meanpet,normalized_pet] = normalize_using_template(meanpet_file,template_dir,tracer,motion_corrected_pet);
        [roi_masks,ref_mask] = get_roi_masks(mask_dir,ref_region.label);
        
        sub_mask_dir = sprintf('%s/%s/masks',data_path,subject);
        [ref_mask,thr] = data_driven_reference_region_correction_fwhm(ref_mask,normalized_meanpet,sub_mask_dir);
        specific_binding_mask = create_specific_binding_mask(normalized_meanpet,thr);
        if(rc)
            remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask,sub_mask_dir);
        end
        tacs = calculate_roi_tacs(normalized_pet,roi_masks);
        input = get_ref_tac(normalized_pet,ref_mask);
        input_qc(subject,input,frames);
        brainmask = create_brainmask(subject,brainmask,specific_binding_mask);
        normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
        smooth_img(normalized_parametric_images,fwhm);
        
    elseif(~dyn && ~mri && plasma)
        
        % (6) process static images without mri but with plasma data
        
        fprintf('%s: Static image, no MRI, plasma input\n',subject);
        
        normalized_pet = normalize_using_template(pet_file,template_dir,tracer);
        input = read_plasma(subject);
        normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
        smooth_img(normalized_parametric_images,fwhm);
        roi_masks = get_roi_masks(mask_dir);
        tacs = calculate_roi_tacs(normalized_pet,roi_masks);
        
    elseif(~dyn && mri && ~plasma)
        
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
        input_qc(subject,input,frames);
        brainmask = create_brainmask(subject,resampled_bet_file,specific_binding_mask);
        parametric_images = calculate_parametric_images(pet_file,input,frames,modeling_options,results_dir,tracer,brainmask);
        deformation_field = spm_segment(mri_file);
        mri_histogram_qc(subject,mri_file);
        normalized_images = normalize_using_mri(mri_file,parametric_images,deformation_field);
        smooth_img(normalized_images(2:end),fwhm);
        
    else
        
        % (8) process static images without mri or plasma data
        
        fprintf('%s: Static image, no MRI, reference tissue input\n',subject);
        
        [roi_masks,ref_mask] = get_roi_masks(mask_dir,ref_region.label);
        normalized_pet = normalize_using_template(pet_file,template_dir,tracer);
        
        sub_mask_dir = sprintf('%s/%s/masks',data_path,subject);
        [ref_mask,thr] = data_driven_reference_region_correction_fwhm(ref_mask,normalized_pet,sub_mask_dir);
        specific_binding_mask = create_specific_binding_mask(normalized_pet,thr);
        remove_nonspecific_binding_from_rois(roi_masks,specific_binding_mask);
        
        input = get_ref_tac(normalized_pet,ref_mask);
        input_qc(subject,input,frames);
        brainmask = create_brainmask(subject,brainmask,specific_binding_mask);
        tacs = calculate_roi_tacs(normalized_pet,roi_masks);
        normalized_parametric_images = calculate_parametric_images(normalized_pet,input,frames,modeling_options,results_dir,tracer,brainmask);
        smooth_img(normalized_parametric_images,fwhm);
        
    end
    
    parametric_image_qc(subject,model);
    fprintf('%s: Starting ROI level visualization and fitting\n ',subject);
    
    visualize_tacs(tacs,input,frames,roi_info,results_dir);
    T = roi_fitting(tacs,input,frames,modeling_options,roi_info,results_dir);
    visualize_fits(T,tacs,input,frames,modeling_options,roi_info,results_dir);
    roi_bars(T,modeling_options,results_dir);
    
    archive_results_new(subject);
    aivo_set_info(subject,'analyzed',1);
    magia_clean_files(subject);
    
catch ME
    error_message = aivo_parse_me(ME);
    aivo_set_info(subject,'error',error_message);
    rethrow(ME);
end

end
