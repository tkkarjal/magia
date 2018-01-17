function [Summary, FRACTIONS, SNR, SNR_dietrich, CJV, CNR,  FBER, EFC, WM2MAX ] = MRIqc(MRIpth, AC)
% Image quality metrics for structural images according to 
% http://mriqc.readthedocs.io/en/stable/iqms/t1w.html#mriqc.qc.anatomical.fber
%
% Inputs: 
% MRIpth := folder containing the structural images & SPM tissue probability maps
% Structural image ID (accession number)
%
% Outputs:
% Summary := the mean, the standard deviation, the 95% and the 5% percentiles of GM, WM, CSF and background (AIR).
% FRACTIONS := Intra cranial volume fractions of GM, WM and CSF
% CJV := Coefficient of (GM and WM) joint variation (higher values are better)
% SNR := Signal to noise ratio within the tissue mask (head mask)
% SNR_dietrich := SNR, using the AIR mask as reference
% CNR := Contrast to noise ratio, is an extension of the SNR calculation to evaluate how separated 
%        the tissue distributions of GM and WM are. Higher values indicate better quality.
% FBER := Foreground to background ratio; defined as the mean energy of image values within the head relative to outside the head. 
%         Higher values are better.
% EFC := Entropy focus criterion, uses the Shannon entropy of voxel intensities as an indication of ghosting and blurring 
%        induced by head motion. Lower values are better.
% WM2MAX := The white-matter to maximum intensity ratio is the median intensity within the WM mask over the 95% percentile 
%           of the full intensity distribution, that captures the existence of long tails due to hyper-intensity of the carotid 
%           vessels and fat. Values should be around the interval [0.6, 0.8]
%
% metrics not implemented yet: 
% artifact detection (art_qi1, art_qi2), 
% residual partial voluming error (rPVE)
% FWHM (full width at half maximum)
% N4ITK improved N3 bias correction
%
% created by Jouni Tuisku 17.1.2018

%test AC='4167494';
%MRIpth = ['/scratch/jouni/Research/Neurotiede/aivo/archive/' AC '/MRI/'];

%set required paths
TargetMRIfile = [MRIpth 'mri_' AC '_full.nii'];

spmGMfile = [MRIpth 'c1mri_' AC '_full.nii'];
spmWMfile = [MRIpth 'c2mri_' AC '_full.nii'];
spmCSFfile = [MRIpth 'c3mri_' AC '_full.nii'];
spmBONEfile = [MRIpth 'c4mri_' AC '_full.nii'];
spmSOFTfile = [MRIpth 'c5mri_' AC '_full.nii'];

%create nifti objects
TargetVol = nifti(TargetMRIfile);
GMvol = nifti(spmGMfile);
WMvol = nifti(spmWMfile);
CSFvol = nifti(spmCSFfile);
BONEvol = nifti(spmBONEfile);
SOFTvol = nifti(spmSOFTfile);

%use binarisation thresholds 0.5
maskidxGM = find(GMvol.dat(:,:,:)>0.5);
maskidxWM = find(WMvol.dat(:,:,:)>0.5);
maskidxCSF = find(CSFvol.dat(:,:,:)>0.5);
maskidxBONE = find(BONEvol.dat(:,:,:)>0.5);
maskidxSOFT = find(SOFTvol.dat(:,:,:)>0.5);
maskidxHEAD = union(union(union(union(maskidxGM,maskidxWM),maskidxCSF),maskidxBONE),maskidxSOFT);

maskhdr = spm_vol_nifti(spmGMfile); % all spm segments have similar dimensions
HEADmask = zeros(maskhdr.dim);
HEADmask(maskidxHEAD)=1;

maskidxAIR = find(HEADmask==0);

%   SUMMARY STATS
%   Mean, standard deviation, 5% percentile and 95% percentile of the distribution of background, CSF, GM and WM.
maskidx = maskidxGM;
info_GM = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),95) prctile(TargetVol.dat(maskidx),5) kurtosis(TargetVol.dat(maskidx)) length(maskidx)];

maskidx = maskidxWM;
info_WM = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),95) prctile(TargetVol.dat(maskidx),5) kurtosis(TargetVol.dat(maskidx)) length(maskidx)];

maskidx = maskidxCSF;
info_CSF = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),95) prctile(TargetVol.dat(maskidx),5) kurtosis(TargetVol.dat(maskidx)) length(maskidx)];

maskidx = maskidxAIR;
info_BG = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),95) prctile(TargetVol.dat(maskidx),5) kurtosis(TargetVol.dat(maskidx)) length(maskidx)];

Summary = [info_GM info_WM info_CSF info_BG];


%VOLUME FRACTIONS (intracranial volume fractions of CSF, GM and WM)
maskidxICV = union(union(maskidxGM,maskidxWM),maskidxCSF);
GMfraction = length(maskidxGM) / length(maskidxICV);
WMfraction = length(maskidxWM) / length(maskidxICV);
CSFfraction = length(maskidxCSF) / length(maskidxICV);
FRACTIONS = [GMfraction WMfraction CSFfraction];

%   SNR: use headmask as foreground mask
n = length(maskidxHEAD);
SNR = mean(TargetVol.dat(maskidxHEAD)) / std(TargetVol.dat(maskidxHEAD))*sqrt( n /(n-1));

%   SNR Dietrich: air mask here should not contain artifacts, but 
DIETRICH_FACTOR = 1.0 / sqrt(2 / (4 - pi));
if ~isempty(maskidxAIR)
    SNR_dietrich = DIETRICH_FACTOR * mean(TargetVol.dat(maskidxHEAD)) / std(TargetVol.dat(maskidxAIR));
else
    disp('SNR Dietrich background mask: AIR is too small!')
end

%   CJV: %binarisation threshold 0.9 used in [Ganzetti2016]
CJV = ( mean(TargetVol.dat(find(GMvol.dat(:,:,:)>0.9))) + mean(TargetVol.dat(find(WMvol.dat(:,:,:)>0.9))) ) / ...
        abs( std(TargetVol.dat(find(GMvol.dat(:,:,:)>0.9))) - std(TargetVol.dat(find(WMvol.dat(:,:,:)>0.9))) );

%   CNR:
CNR = abs( mean(TargetVol.dat(maskidxGM)) - mean(TargetVol.dat(maskidxWM))) / ... 
      sqrt(  std(TargetVol.dat(maskidxAIR))^2 +  std(TargetVol.dat(maskidxGM))^2 + std(TargetVol.dat(maskidxWM))^2  );

%FBER (Foreground to background ratio, rotation mask(?) not used here)
if ~isempty(maskidxAIR) %median might be 0
    fg_mu = median(abs(TargetVol.dat(maskidxHEAD)).^2);
    bg_mu = median(abs(TargetVol.dat(maskidxAIR)).^2);
    if (bg_mu < 1.0e-3) 
        FBER = 0;
    else
        FBER = fg_mu / bg_mu;
    end
    disp('FBER background mask: AIR is too small!')
end


%   EFC (Entropy focus criterion)
n_vox = length(maskidxHEAD);
% Calculate the maximum value of the EFC (which occurs any time all
% voxels have the same value)
efc_max = 1.0 * n_vox * (1.0 / sqrt(n_vox)) * log(1.0 / sqrt(n_vox));

% Calculate the total image energy
b_max = sqrt(sum((TargetVol.dat(maskidxHEAD).^2)));
%origcode : b_max = sqrt((img[framemask == 0]**2).sum())

EFC = (1.0 / efc_max) * sum( (TargetVol.dat(maskidxHEAD)./ b_max) .* log((TargetVol.dat(maskidxHEAD) + 1e-16) ./ b_max) );
%orig code: EFC = (1.0 / efc_max) * sum((img[framemask == 0] / b_max) * log((img[framemask == 0] + 1e-16) / b_max))


%WM2MAX (values should be around the interval [0.6 0.8])
WM2MAX = mean(TargetVol.dat(maskidxWM)) / pctile(TargetVol.dat(maskidxHEAD), 99.95);
%orig code: float(mu_wm / np.percentile(img.reshape(-1), 99.95))


    
end


