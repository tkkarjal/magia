function parametric_images = calculate_parametric_images(pet_filename,input,frames,modeling_options,outputdir,tracer,varargin)

model = modeling_options.model;
if(nargin==7)
    brainmask = varargin{1};
end

switch lower(model)
    case 'srtm'
        theta3_lb = modeling_options.theta3_lb;
        theta3_ub = modeling_options.theta3_ub;
        nbases = modeling_options.nbases;
        isotope = aivo_get_isotope_from_tracer(tracer);
        switch lower(isotope)
            case '11c'
                decaytime = 20.4;
            case '18f'
                decaytime = 109.9;
            otherwise
                error('Unknown halflife for %s.',isotope);
        end
        parametric_images = Gunn1997_nifti_mask(theta3_lb,theta3_ub,nbases,decaytime,input,frames,pet_filename,brainmask,outputdir);
    case 'patlak'
        start_time = modeling_options.start_time;
        cutFrame = modeling_options.end_frame;
        parametric_images = PatlakPlasma_nifti(input,start_time,cutFrame,frames,pet_filename,brainmask,outputdir);
    case 'patlak_ref'
        start_time = modeling_options.start_time;
        cutTime = modeling_options.cut_time;
        filter_size = modeling_options.filter_size;
        parametric_images = PatlakRef_nifti(input,start_time,cutTime,frames,pet_filename,filter_size,brainmask,outputdir);
    case 'fur'
        start_time = modeling_options.start_time;
        end_time = modeling_options.end_time;
        ic = modeling_options.ic;
        parametric_images = {magia_calculate_fur_image(input,frames,start_time,end_time,ic,pet_filename,brainmask,outputdir)};
    case 'suvr'
        start_time = modeling_options.start_time;
        end_time = modeling_options.end_time;
        parametric_images = {magia_suvr_image(start_time,end_time,input,frames,pet_filename,brainmask,outputdir)};
%     case 'logan'
%         startTime = modeling_options.logan_modeling_options.startTime;
%         endTime = modeling_options.logan_modeling_options.endTime;
%         parametric_images = {logan_image(startTime,endTime,input,frames,pet_filename,brainmask,outputdir)};
    case 'two_tcm'
        msg = 'Voxelwise fitting with 2-tissue compartment model is too sensitive to noise... Using';
        switch tracer
            case '[18f]fmpep-d2'
                msg = sprintf('%s Logan instead.',msg);
                warning(msg);
            otherwise
                
        end
    otherwise
        error('Voxelwise modeling with %s has not been implemented.',model);
end

end