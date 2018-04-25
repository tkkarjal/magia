function [motion_corrected_file,meanpet_file] = motion_correction(filename,varargin)
% Performs motion correction of the file using SPM's motion correction
% algorithm. The motion correction is done in two stages: First, all
% volumes are realigned with the first volume of the image, then mean image
% is calculated, and all volumes are finally realigned with the mean
% image.
%
% Inputs
%    filename = name of the 4D nifti file that the user wants to
%    motion-correct, including full path to the file
% Outputs
%    motion_corrected_file = name of the motion corrected 4D nifti file,
%    including full path to the file
%    meanpet_file = name of the mean image over all volumes, including full
%    path to the file

if(nargin==1)
    ref_frame = 0;
    fwhm = 7;
    rtm = 1;
elseif(nargin==4)
    ref_frame = varargin{1};
    fwhm = varargin{2};
    rtm = varargin{3};
else
    error('Invalid number of input arguments.\n');
end

bad_frames = magia_identify_bad_frames(filename);
[p,n,e] = fileparts(filename);
images = cellstr(spm_select('ExtFPList',p,[n e]));
images = images(~bad_frames);

if(~ref_frame)
    ref_frame = ceil(size(images,1)/2);
end
h = images{ref_frame};
images{ref_frame} = images{1};
images{1} = h;

prefix = 'r';

matlabbatch{1}.spm.spatial.realign.estwrite.data = {images}';
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = fwhm;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = rtm;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = prefix;

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

matlabbatch_filename = sprintf('%s/matlabbatch_realign.mat',p);
save(matlabbatch_filename,'matlabbatch');

motion_corrected_file = fullfile(p,[prefix n e]);
meanpet_file = add_prefix(filename,'mean');

%% Replace the bad frames

if(any(bad_frames))
    V0 = spm_vol(filename);
    V = spm_vol(motion_corrected_file);
    V(bad_frames) = V0(bad_frames);
    img = spm_read_vols(V);
    spm_write_4d_nifti(V,img,motion_corrected_file);
end

%% Flip the motion parameters so that the first frame is first

motion_parameter_file = fullfile(p,['rp_' n '.txt']);
Q = load(motion_parameter_file);
h = Q(ref_frame,:);
Q(ref_frame,:) = Q(1,:);
Q(1,:) = h;

if(any(bad_frames))
    H = zeros(length(V),6);
    H(~bad_frames,:) = Q;
    
    bad_idx = find(bad_frames);
    M = length(bad_idx);
    
    if(M == 1)
        if(bad_idx < length(V))
            H(bad_idx,:) = H(bad_idx+1,:);
        else
            H(bad_idx,:) = H(bad_idx-1,:);
        end
    end
    Q = H;
end

save(motion_parameter_file,'Q','-ascii');

end
