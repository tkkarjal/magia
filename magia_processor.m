function magia_processor(subject,specs,modeling_options)
%% Processes a brain PET study following the given processing instructions
%
% The first input argument defines a subject ID. Magia assumes that a
% folder with exactly the same name exists under getenv('DATA_DIR').
% Please see https://github.com/tkkarjal/magia/wiki/4.-Preparing-your-data-for-MAGIA
% for detailed information about the required folder structre.
%
% The second input - specs - is a struct that should contain two
% substructs: study and magia. specs.study contains information about the
% study, and those information are more or less independent of
% Magia-processing. specs.magia, on the other hand, specifies information
% about how Magia should process the study.
%
% specs.study should contain the following fields:
%
% - frames   (always necessary)
% - tracer   (always necessary)
% - dose     (always recommended and necessary if calculating SUVs)
% - weight   (always recommended and necessary if calculating SUVs)
% - mri_code (necessary if ROIs are defined using FreeSurfer or if spatial normalization is done via MRI).
%
% specs.magia should contain the following fields:
%
% - model                               (always necessary)
% - cpi (calculate parametric images)   (always necessary)
% - dc (decay-corrected)                (always necessary)
% - rc (roi-correction)                 (always necessary)
% - roi_type                            (always necessary)
% - roi_fwhm                            (always necessary)
% - norm_method                         (necessary if cpi = 1 or if roi_type = 'atlas')
% - mni_roi_mask_dir                    (necessary if roi_type = 'atlas')
% - template                            (necessary if norm_method = 'pet')
% - input_type                          (necessary unless model = 'suv')
% - fwhm_pre                            (necessary if cpi = 1)
% - fwhm_post                           (necessary if cpi = 1)
% - classfile                           (necessary if input_type = 'sca_ref')
% - mc_ref_frame                        (necessary for dynamic studies)
% - mc_fwhm                             (necessary for dynamic studies)
% - mc_rtm                              (necessary for dynamic studies)
% - mc_excluded_frames                  (necessary for dynamic studies)
%
%
% The third input specifies the modeling options.

% Tomi Karjalainen
% Last edited: September 24th, 2019

%% Initialize

magia_check_envs();

data_path = getenv('DATA_DIR');
subject_dir = sprintf('%s/%s',data_path,subject);

% Make sure the subject has image files
found = magia_check_found(subject);
if(~found)
    error('%s: Could not find image files. Please make sure the subject has its own folder under %s.',subject,data_path);
end

% Clean the working directory
magia_clean_files(subject);

% Write the used specs to a text file
specs = magia_match_input_to_model(specs);
magia_write_specs(subject,specs);

% Write the used modeling options to a text file
magia_write_modeling_options(subject,modeling_options);

% Write the Magia githash to a text file
githash = magia_get_githash();
magia_write_githash(subject,githash);

% Create necessary directories
results_dir = sprintf('%s/results',subject_dir);
if(~exist(results_dir,'dir'))
    mkdir(results_dir);
end
masks_dir = sprintf('%s/masks',subject_dir);
if(~exist(masks_dir,'dir'))
    mkdir(masks_dir);
end

%% Get PET file and if needed select the requested subset of frames

fprintf('Starting processing of %s...\n',subject);
pet_file = magia_get_pet_file(subject);
if(specs.magia.cut_time)
    frame_idx = specs.study.frames(:,2) <= specs.magia.cut_time;
    specs.study.frames = specs.study.frames(frame_idx,:);
    num_frames = sum(frame_idx);
    pet_file = magia_select_frames(pet_file,num_frames);
end

%% Preprocessing
% The PET data need to be decay-corrected to injection time. By default,
% PET scanners decay-correct the images to the scan start time. In many
% cases, the scan start time is identical to injection time. In late scans,
% however, this is not the case.
%
% Whenever the data have been decay-corrected to injection time (dc = 1)
% outside Magia, this step is unnecessary. However, if the data have not
% been decay-corrected to injection time (dc = 0), then Magia executes the
% decay-correction.
%
% Note that Magia assumes that the first element of the frames-matrix
% specifies the delay, in minutes, between injection and scan start time.

if(~specs.magia.dc)
    fprintf('%s: Decay-correcting the PET-data\n',subject);
    decay_correct_to_injection_time(pet_file,specs.study.frames,specs.study.tracer);
end

% Center the image to center of mass, and if a PET template is specified in
% the specs, then the sum image could be coregistered with the template

fprintf('%s: Centering the PET image\n',subject);
magia_center_image(pet_file,specs.study.tracer); % This function should be re-written

% Motion-correction
dyn = magia_test_dyn(pet_file);
if(dyn)
    fprintf('%s: Re-aligning the frames\n',subject);
    [pet_file,meanpet_file] = magia_motion_correction(pet_file,specs.magia.mc_ref_frame,specs.magia.mc_fwhm,specs.magia.mc_rtm,specs.magia.mc_excluded_frames);
    motion_parameter_qc(subject);
else
    meanpet_file = pet_file;
end

%% Get ROI masks and MNI-transformations
% Magia can define ROIs either via FreeSurfer of via MNI atlases.
%
% If you have a high-quality MRI of the subject's brain, then it is highly
% recommended to use FreeSurfer-based ROIs as well as MRI-based spatial
% normalization. However, FreeSurfer may have trouble with MRIs if the
% contrast between grey and white matter is poor. In such cases,
% atlas-based ROIs may be more accurate.
%
% The MRI-based spatial normalization routine is not as sensitive to the
% grey-to-white matter contrast of the MRI as the FreeSurfer procedure, so
% using MRI-based spatial normalization typically produces good results
% even with relatively low-quality MRIs. In other words, it is recommended
% to do spatial normalization via MRIs, unless you know what you are doing.
%
% The ROI masks will be written in the native PET space. Thus, if atlas-
% based ROIs are used, they are mapped from MNI space to the subject space.
%
% As a quality-control check, please always ensure that the ROIs look good
% on top of the (mean) PET-image.

switch specs.magia.roi_type
    case 'atlas'
        if(isfield(specs.magia,'mni_roi_mask_dir'))
            mni_roi_masks = get_filenames(specs.magia.mni_roi_mask_dir,'*.nii');
            [~,roi_labels] = cellfun(@fileparts,mni_roi_masks,'UniformOutput',false);
            fprintf('%s: Copying atlas-based ROI masks\n',subject);
            for i = 1:length(mni_roi_masks)
                copyfile(mni_roi_masks{i},masks_dir,'f');
                mni_roi_masks{i} = fullfile(masks_dir,[roi_labels{i} '.nii']);
            end
        else
            error('%s: Could not use atlas-based ROIs because the directory containing the atlas-based ROI masks was not specified.',subject);
        end
        switch specs.magia.norm_method
            case 'mri'
                fprintf('%s: Fetching the MRI file\n',subject);
                mri_file = magia_get_mri_file(subject,I.mri_code);
                fprintf('%s: Coregistering the MRI to the PET\n',subject);
                spm_coregister_estimate(meanpet_file,mri_file,'');
                coreg_qc(subject,meanpet_file,mri_file);
                fprintf('%s: Segmenting the MRI\n',subject);
                [sub2mni,mni2sub] = spm_segment(mri_file);
                fprintf('%s: Warping the atlas-based ROIs into native space\n',subject);
                roi_masks_temp = normwrite_df(mni_roi_masks,mni2sub,0);
                roi_masks = spm_coregister_reslice(meanpet_file,roi_masks_temp,0);
                roi_masks = remove_first_characters(roi_masks,2);
                cellfun(@delete,roi_masks_temp);
            case 'pet'
                if(specs.magia.cpi)
                    fprintf('%s: Estimating the subject-to-MNI transformation using the template file %s\n',subject,specs.magia.template);
                    if(exist(specs.magia.template,'file'))
                        sub2mni = normest_template(meanpet_file,specs.magia.template,8,0,'mni');
                    else
                        error('%s: Could not estimate the subject-to-MNI transformation because the specified template file %s does not exist.',subject,specs.magia.template);
                    end
                end
                fprintf('%s: Estimating the MNI-to-subject transformation using the template file %s\n',subject,specs.magia.template);
                if(exist(specs.magia.template,'file'))
                    mni2sub = normest_template(specs.magia.template,meanpet_file,0,8,'none');
                else
                    error('%s: Could not estimate the MNI-to-subject transformation because the specified template file %s does not exist.',subject,specs.magia.template);
                end
                fprintf('%s: Warping the atlas-based ROIs into native space\n',subject);
                roi_masks_temp = normwrite_sn(mni_roi_masks,mni2sub,0);
                fprintf('%s: Reslicing the ROI masks to match the PET data\n',subject);
                roi_masks = spm_coregister_reslice(meanpet_file,roi_masks_temp,0);
                roi_masks = remove_first_characters(roi_masks,1);
                cellfun(@delete,roi_masks_temp);
            otherwise
                error('%s: Unknown ''norm_method'' ''%s''. The ''norm_method'' varialbe must be either ''mri'' or ''pet''. ',subject,specs.magia.norm_method);
        end
        cellfun(@delete,mni_roi_masks);
    case 'freesurfer'
        roi_info = magia_get_freesurfer_roi_info(specs);
        roi_labels = roi_info.labels;
        fprintf('%s: Fetching the MRI files\n',subject);
        [mri_file,seg_file] = process_mri(subject,specs.study.mri_code);
        fprintf('%s: Coregistering the MRI to the PET\n',subject);
        spm_coregister_estimate(meanpet_file,mri_file,{seg_file});
        coreg_qc(subject,meanpet_file,mri_file);
        fprintf('%s: Reslicing the seg file to match the PET data\n',subject);
        seg_file = spm_coregister_reslice(meanpet_file,seg_file,0);
        fprintf('%s: Creating FreeSurfer-based ROI-masks\n',subject);
        roi_masks = create_roi_masks2(seg_file,roi_info);
        if(specs.magia.cpi)
            switch specs.magia.norm_method
                case 'mri'
                    fprintf('%s: Segmenting the MRI\n',subject);
                    sub2mni = spm_segment(mri_file);
                case 'pet'
                    warning('%s: Starting PET-template-based spatial normalization even if ROIs were defined using FreeSurfer. Typically, it is advisable to use MRI-based spatial normalization if the MRI quality is sufficient for FreeSurfer.',subject);
                    if(exist(specs.magia.template,'file'))
                        fprintf('%s: Estimating the subject-to-MNI transformation using the template file %s\n',subject,specs.magia.template);
                        sub2mni = normest_template(meanpet_file,specs.magia.template,8,0,'mni');
                    else
                        error('%s: Could not estimate the subject-to-MNI transformation because the specified template file %s does not exist.',subject,specs.magia.template);
                    end
                otherwise
                    error('%s: Unknown ''norm_method'' ''%s''. The ''norm_method'' varialbe must be either ''mri'' or ''pet''. ',subject,specs.magia.norm_method);
            end
        end
    otherwise
        error('%s: Unknown ''roi_type'' ''%s''. The ''roi_type'' varialbe must be either ''freesurfer'' or ''atlas''. ',subject,specs.magia.roi_type);
end

%% Build reference region mask
% The reference region is created in three stages if FreeSurfer is used to
% create the ROIs, and in two stages if the ROIs are atlas-based.
% 
% If FreeSurfer is used, then first the reference region is extracted from
% the aparc+aseg.mgz image. This 'raw' reference region is then subjected
% to anatomical reference-region-correction, after which it goes through
% data-driven reference-region-correction. The anatomical
% reference-region-correction is tracer-dependent.
%
% If atlas-based ROIs are used, then the anatomical reference-region-
% correction is skipped.

if(strcmp(specs.magia.input_type,'ref'))
    fprintf('%s: Creating reference region mask\n',subject);
    if(strcmp(specs.magia.roi_type,'freesurfer'))
        ref_region = magia_get_ref_region(specs.study.tracer);
        if(~isempty(ref_region))
            ref_mask = magia_create_fs_ref_mask(seg_file,ref_region);
        else
            error('%s: No reference region has been defined for the tracer %s.',subject,specs.study.tracer);
        end
        ref_mask = anatomical_reference_region_correction2(ref_mask,specs.study.tracer,seg_file);
    else
        [ref_mask,roi_masks,roi_labels] = magia_get_ref_mask(roi_masks,specs.study);
        if(isempty(ref_mask))
            error('%s: Could not find reference region mask among the atlas-specified ROIs. Please make sure that the correct reference region for the tracer is among the ROIs.',subject);
        end
    end
    ref_mask = data_driven_reference_region_correction_fwhm(ref_mask,meanpet_file);
end

%% ROI-correction
% The ROI masks can be modified in two ways: First, it is possible to
% slightly extend the ROIs by smoothing and thresholding them. Second, it
% is possible to discard the voxels whose mean radioactivity are lowest
% within each ROI. This second part is called ROI-correction.
%
% In the second part, voxels in each ROI are clustered into three clusters
% that are functionally more homogenous than the original ROI. Then
% cluster-specific mean radioactivities are calculated. Finally, the voxels
% belonging to the cluster with lowest radioactivity are dropped from the
% ROI. This procedure makes the ROIs less likely to contain voxels outside
% brain tissue. It also makes the ROIs follow the PET signal more closely.
% Also humans typically delineate ROIs using information from both MR and
% PET images, and thus the corrected ROIs may more closely reflect
% human-drawn ROIs.
%
% In practice, the ROI-correction makes the PET-derived outcome measures
% positively biased (compared to not using it). However, this bias is often
% meaningful because the correction makes the ROIs more likely to contain
% signal only from the brain (and not e.g. from the ventricles).
%
% By default, the ROI-correction is NOT used. It should not be used e.g.
% when studying patient populations that may have altered PET signal.

if(specs.magia.fwhm_roi > 0)
    roi_masks = magia_smooth_rois(roi_masks,specs.magia.fwhm_roi);
end

if(specs.magia.rc)
    fprintf('%s: Starting ROI-correction\n',subject);
    magia_correct_rois(roi_masks,meanpet_file);
end

%% Read the input
%
% Note that Magia does not correct for metabolites, extrapolate the curves,
% etc. In other words, the plasma and blood curves should be fully
% processed before they can be used in Magia.

switch specs.magia.input_type
    case 'plasma'
        fprintf('%s: Reading the plasma input\n',subject);
        cp = magia_get_input(subject,'plasma');
        cp = magia_match_units(cp,pet_file);
    case 'blood'
        fprintf('%s: Reading the blood input\n',subject);
        cb = magia_get_input(subject,'blood');
        cb = magia_match_units(cb,pet_file);
    case 'plasma&blood'
        fprintf('%s: Reading the plasma and blood inputs\n',subject);
        cp = magia_get_input(subject,'plasma');
        cp = magia_match_units(cp,pet_file);
        cb = magia_get_input(subject,'blood');
        cb = magia_match_units(cb,pet_file);
        if(~isequal(cp(:,1),cb(:,1)))
            error('%s: Time-points for plasma and blood inputs differ. Please ensure that both curves are sampled at the same time points.',subject);
        else
            t_input = cp(:,1);
        end
    case 'ref'
        fprintf('%s: Reading the reference input\n',subject);
        cr = get_ref_tac(pet_file,ref_mask);
        cr = magia_correct_refinput(cr,specs.study.frames);
        if(any(isnan(cr)))
            error('%s: Found NaNs in the reference input. Please make sure that the whole brain is visible in all the frames.',subject);
        end
    case 'sca_ref'
        if(isfield(specs.magia,'classfile'))
            if(exist(specs.magia.classfile,'file'))
                if(strcmp(specs.magia.roi_type,'freesurfer'))
                    fprintf('%s: Starting to calculate the SCA_ref input...\n',subject);
                    cr = superpk_4class_TPC(seg_file,pet_file,specs.study.frames,specs.magia.classfile);
                else
                    error('%s: Use of ''sca_ref'' as the ''input_type'' requires FreeSurfer-based ROIs. Please set ''freesurfer'' as the ''roi_type''.',subject);
                end
            else
                error('%s: Could not create cluster-based reference region because the specified classfile %s does not exist.',subject,specs.magia.classfile);
            end
        else
            error('%s: Could not create cluster-based reference region because the classfile was not specified.',subject);
        end
    otherwise
        % no input needed (e.g. SUV)  
end

%% Calculate, visualize and save ROI time-activity curves
% Magia calculates ROI-specific time-activity curves (TACs) by averaigng
% the radioactivity concentration inside each of the ROIs.

fprintf('%s: Calculating ROI TACs\n',subject);
[tacs,num_voxels] = magia_calculate_roi_tacs(pet_file,roi_masks);
N = size(tacs,1);
tacs_fname = sprintf('%s/tacs.mat',results_dir);
switch specs.magia.input_type
    case 'plasma'
        fprintf('%s: Visualizing the TACs\n',subject);
        magia_visualize_tacs(tacs,cp,specs.study.frames,roi_labels,results_dir);
        fprintf('%s: Saving the TACs\n',subject);
        s = struct('tacs',tacs,'cp',cp,'frames',specs.study.frames,'roi_labels',{roi_labels},'num_voxels',num_voxels); %#ok
        save(tacs_fname,'-struct','s');
    case 'blood'
        fprintf('%s: Visualizing the TACs\n',subject);
        magia_visualize_tacs(tacs,cb,specs.study.frames,roi_labels,results_dir);
        fprintf('%s: Saving the TACs\n',subject);
        s = struct('tacs',tacs,'cb',cb,'frames',specs.study.frames,'roi_labels',{roi_labels},'num_voxels',num_voxels); %#ok
        save(tacs_fname,'-struct','s');
    case 'plasma&blood'
        fprintf('%s: Visualizing the TACs\n',subject);
        magia_visualize_tacs(tacs,cp,specs.study.frames,roi_labels,results_dir);
        fprintf('%s: Saving the TACs\n',subject);
        s = struct('tacs',tacs,'cp',cp,'cb',cb,'frames',specs.study.frames,'roi_labels',{roi_labels},'num_voxels',num_voxels); %#ok
        save(tacs_fname,'-struct','s');
    case {'ref','sca_ref'}
        fprintf('%s: Visualizing the TACs\n',subject);
        magia_visualize_tacs(tacs,cr,specs.study.frames,roi_labels,results_dir);
        fprintf('%s: Saving the TACs\n',subject);
        s = struct('tacs',tacs,'cr',cr,'frames',specs.study.frames,'roi_labels',{roi_labels},'num_voxels',num_voxels); %#ok
        save(tacs_fname,'-struct','s');
end

%% Pre-model smoothing (for parametric images)
% Pre-smoothing is often useful because the voxel-level time-activity
% curves tend to be very noisy, sometimes so noisy that the voxel-level
% fits produce results that are biologically implausible. Smoothing
% increases the signal-to-noise ratio of the voxel-level time-activity
% curves, thus often providing more meaningful results.

if(specs.magia.cpi)
    if(specs.magia.fwhm_pre)
        fprintf('%s: Spatially smoothing the PET data before calculation of parametric images (FWHM = %f)\n',subject,specs.magia.fwhm_pre);
        smooth_img({pet_file;meanpet_file},specs.magia.fwhm_pre);
        pet_file = add_prefix(pet_file,'s');
        meanpet_file = add_prefix(meanpet_file,'s');
    end
end

%% Create brainmask (for parametric images)
% The meanpet file is used to create a mask defining the voxels where
% voxel-level model estimation will be done. The mask is meant to be very
% conservative and only exclude voxels that are clearly outside the brain.

if(specs.magia.cpi)
    fprintf('%s: Creating brainmask\n',subject);
    brainmask = magia_create_brainmask(meanpet_file,specs.magia.fwhm_pre);
end

%% Pharmacokinetic modeling
% Creates the requested outcome-measures at ROI-level, and if requested,
% also computes parametric images.
%
% Magia currently supports the following models:
%
% - suv
% - suvr
% - srtm
% - logan
% - logan_ref
% - ma1
% - patlak
% - patlak_ref
% - fur
% - two_tcm (for ROIs only, not properly tested)

fprintf('%s: Starting modeling\n',subject);

switch specs.magia.model
    case 'suv'
        if(isnan(specs.study.dose))
            error('%s: Could not calculate SUVs because the injected dose was not specified.',subject);
        end
        if(isnan(specs.study.weight))
            error('%s: Could not calculate SUVs because the weight of the subject was not specified.',subject);
        end
        suvs = tacs./(specs.study.dose/specs.study.weight);
        visualize_suvs(suvs,specs.study.frames,roi_info,results_dir);
        if(specs.magia.cpi)
            parametric_images = magia_suv_image(pet_file,specs.study.dose,specs.study.weight,brainmask,results_dir);
        end
    case 'suvr'
        X = magia_suvr(cr,tacs,specs.study.frames,modeling_options.start_time,modeling_options.end_time);
        T = array2table(X,'VariableNames',{'SUVR'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        if(specs.magia.cpi)
            parametric_images = {magia_suvr_image(modeling_options.start_time,modeling_options.end_time,cr,specs.study.frames,pet_file,brainmask,results_dir)};
        end
    case 'srtm'
        X = zeros(N,3);
        for i = 1:N
            fprintf('%s: SRTM: Fitting ROI %.0f/%.0f...\n',subject,i,N);
            [~,X(i,:)] = fit_srtm(tacs(i,:),cr,specs.study.frames,modeling_options.lb,modeling_options.ub,50);
        end
        T = array2table(X,'VariableNames',{'R1','k2','BPnd'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        magia_visualize_fit_srtm(T,tacs,cr,specs.study.frames,roi_labels,results_dir);
        if(specs.magia.cpi)
            half_life = get_half_life(specs.study.tracer);
            parametric_images = Gunn1997_nifti_mask(modeling_options.theta3_lb,modeling_options.theta3_ub,modeling_options.nbases,half_life,cr,specs.study.frames,pet_file,brainmask,results_dir);
        end
    case 'logan'
        [Vt,intercept,X,Y,k] = magia_fit_logan(tacs,cp,specs.study.frames,modeling_options.start_time,modeling_options.end_time);
        T = array2table([Vt intercept],'VariableNames',{'Vt','intercept'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        magia_visualize_fit_logan(Vt,intercept,X,Y,k,roi_labels,results_dir);
        if(specs.magia.cpi)
            parametric_images = magia_logan_image(pet_file,cp,specs.study.frames,brainmask,modeling_options.start_time,modeling_options.end_time,results_dir);
        end
    case 'logan_ref'
        [DVR,intercept,X,Y,k] = magia_fit_logan_ref(tacs,cr,specs.study.frames,modeling_options.start_time,modeling_options.end_time,modeling_options.refk2);
        T = array2table([DVR intercept],'VariableNames',{'DVR','intercept'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        magia_visualize_fit_logan_ref(DVR,intercept,X,Y,k,roi_labels,results_dir);
        if(specs.magia.cpi)
            parametric_images = magia_logan_ref_image(pet_file,cr,specs.study.frames,brainmask,modeling_options.start_time,modeling_options.end_time,modeling_options.refk2,results_dir);
        end
    case 'ma1'
        [Vt,intercept,k,b1,b2,auc_input,auc_pet] = magia_fit_ma1(tacs,cp,specs.study.frames,modeling_options.start_time,modeling_options.end_time);
        T = array2table([Vt intercept],'VariableNames',{'Vt','intercept'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        magia_visualize_fit_ma1(tacs,b1,b2,auc_input,auc_pet,k,specs.study.frames,roi_labels,results_dir)
        if(specs.magia.cpi)
            parametric_images = magia_ma1_image(pet_file,cp,specs.study.frames,brainmask,modeling_options.start_time,modeling_options.end_time,results_dir);
        end
    case 'fur'
        furs = magia_calculate_fur(cp,tacs,specs.study.frames,modeling_options.start_time,modeling_options.end_time,modeling_options.ic);
        T = array2table(furs,'VariableNames',{'FUR'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        if(specs.magia.cpi)
            parametric_images = {magia_calculate_fur_image(cp,specs.study.frames,modeling_options.start_time,modeling_options.end_time,modeling_options.ic,pet_file,brainmask,results_dir)};
        end
    case 'patlak'
        [Ki,intercept,x,Y,k] = magia_fit_patlak(cp,tacs,specs.study.frames,modeling_options.start_time,modeling_options.end_frame);
        T = array2table([Ki intercept],'VariableNames',{'Ki','intercept'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        magia_visualize_fit_patlak(Ki,intercept,x,Y,k,roi_labels,results_dir);
        if(specs.magia.cpi)
            parametric_images = magia_patlak_image(pet_file,cp,specs.study.frames,brainmask,modeling_options.start_time,modeling_options.end_frame,results_dir);
        end
    case 'patlak_ref'
        [Ki_ref,intercept,x,Y,k] = magia_fit_patlak_ref(cr,tacs,specs.study.frames,modeling_options.start_time,modeling_options.end_time);
        T = array2table([Ki_ref intercept],'VariableNames',{'Ki_ref','intercept'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        magia_visualize_fit_patlak_ref(Ki_ref,intercept,x,Y,k,roi_labels,results_dir);
        if(specs.magia.cpi)
            parametric_images = magia_patlak_ref_image(pet_file,cr,specs.study.frames,brainmask,modeling_options.start_time,modeling_options.end_time,results_dir);
        end
    case 'two_tcm'
        X = zeros(N,6);
        lb = [modeling_options.k1_lb modeling_options.k1k2_lb modeling_options.k3_lb modeling_options.k3k4_lb modeling_options.vb_lb];
        ub = [modeling_options.k1_ub modeling_options.k1k2_ub modeling_options.k3_ub modeling_options.k3k4_ub modeling_options.vb_ub];
        for i = 1:N
            fprintf('%s: Two-tissue compartmental model: Fitting ROI %.0f/%.0f...\n',subject,i,N);
            roi_tac = tacs(i,:);
            [~,x_optim,~,vt] = magia_fit_2tcm_iterative(roi_tac,t_input,cp(:,2),cb(:,2),specs.study.frames,lb,ub);
            X(i,1:5) = x_optim;
            X(i,6) = vt;
        end
        T = array2table(X,'VariableNames',{'K1','K1k2','k3','k3k4','vb','vt'},'RowNames',roi_labels);
        magia_write_roi_results(T,results_dir);
        % magia_visualize_fit_2tcm(T,tacs,cp,cb,specs.study.frames,modeling_options,roi_info,results_dir);
        if(specs.magia.cpi)
            start_time = magia_get_logan_default_options(specs.study.tracer,'start_time');
            end_time = magia_get_logan_default_options(specs.study.tracer,'end_time');
            parametric_images = magia_logan_image(pet_file,cp,specs.study.frames,brainmask,start_time,end_time,results_dir);
        end
    otherwise
        error('%s: Unknown model: %s',subject,specs.magia.model);
end

fprintf('%s: Finished with modeling\n',subject);

%% Post-processing (for parametric images)
% Parametric images, if calculated, are spatially normalized to MNI space,
% after which they are smooted, if requested, with a Gaussian kernel.

if(specs.magia.cpi)
    % Spatially normalize images to MNI space using the previously
    % calculated mapping sub2mni
    fprintf('%s: Spatially normalizing the images to MNI space\n',subject);
    switch specs.magia.norm_method
        case 'mri'
            normalized_images = normwrite_df([mri_file;parametric_images],sub2mni,1);
        case 'pet'
            normalized_images = normwrite_sn([meanpet_file;parametric_images],sub2mni,1);
    end
    if(specs.magia.fwhm_post)
        % Smooth the normalized parametric images
        fprintf('%s: Spatially smoothing the normalized parametric images (FWHM = %f)\n',subject,specs.magia.fwhm_post);
        smooth_img(normalized_images(2:end),specs.magia.fwhm_post);
    end
end

fprintf('%s: Ready\n',subject);

end