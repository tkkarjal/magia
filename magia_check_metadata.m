function [I, modeling_options] = magia_check_metadata(image_id, I, modeling_options)
% Checks if the metadata in I and the modeling_options are correctly
% specified, and throws an error message if crucial information is missing.

%% TRACER

tracer = I.tracer;
if(strcmp(tracer,'unknown'))
    error('Unknown tracer for %s.',image_id);
end

%% FRAMES

frames = I.frames;
if(isempty(frames) || strcmp(frames,'unknown'))
    error('Frames have not been specified for %s.',image_id);
end
frames = parse_frames_string(frames);

if(frames(1,2) - frames(1,1) >= 30)
    frames = frames/60;
end
I.frames = frames;

%% FWHM

fwhm = I.fwhm;
if(isnan(fwhm))
    fwhm = 8;
    I.fwhm = fwhm;
end

%% USE_MRI & MRI

%% USE_MRI & MRI

use_mri = I.use_mri;
mri = I.mri;

if(isnan(use_mri))
    if(strcmp(mri,'null') || strcmp(mri,'0'))
        use_mri = 0;
    else
        use_mri = 1;
    end
end

if(use_mri)
    mri_found = magia_check_mri_found(mri);
    if(~mri_found)
        error('Cannot magia PET study %s because the MRI (%s) that was specified was not found.',image_id,mri);
    end
end
I.mri = mri;
I.use_mri = use_mri;

%% FREESURFED

if(use_mri)
    freesurfed = magia_check_freesurfed(mri);
    I.freesurfed = freesurfed;
end

%% PLASMA

plasma = I.plasma;
if(isnan(plasma))
    plasma = 0;
end
if(plasma)
    plasma_found = magia_check_plasma_found(image_id);
    if(~plasma_found)
        error('Cannot magia the PET study %s because the plasma file could not be found.',image_id);
    end
end
I.plasma = plasma;

%% RC

rc = I.rc;
if(isnan(rc) || rc == -1)
    rc = 1;
    I.rc = rc;
end

%% DYN

dyn = I.dynamic;
if(isnan(dyn))
    num_frames = size(frames,1);
    if(num_frames > 1)
        dyn = 1;
    else
        dyn = 0;
    end
    I.dynamic = dyn;
end

%% DC

dc = I.dc;
if(isnan(dc) || dc == -1)
    error('Cannot magia %s because it was not specified if the data have already been decay-corrected or not.',image_id);
end

%% ROI_SET

if(use_mri)
    roi_set = 'tracer_default';
else
    roi_set = modeling_options.roi_set;
end
if(~use_mri && strcmp(roi_set,'tracer_default'))
    if(strcmp(tracer,'[18f]fdg'))
        roi_set = '[18f]fdg_atlas';
    else
        roi_set = 'atlas';
    end
end
modeling_options.roi_set = roi_set;

end
