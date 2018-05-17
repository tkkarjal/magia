function [Summary, FRACTIONS, CJV, CNR, SNR, SNR_dietrich, FBER, EFC, WM2MAX ] = MRIqc(MRIpth, AC, resultfile)

%currently not implemented: 
% artifact detection (art_qi1, art_qi2), 
% residual partial voluming error (rPVE)
% FWHM full width at half maximum
% N4ITK: improved N3 bias correction

%test AC='4167494';
%MRIpth = ['/scratch/jouni/Research/Neurotiede/aivo/archive/' AC '/MRI/'];

%test subject
% MRIpth='/scratch/janne/mriqc/dataset/ds001/sub-01/anat/';
% AC = 'testi';
% resultfile = '/scratch/janne/mriqc/sub01test.csv';

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

%VOLUME FRACTIONS (intracranial volume fractions of CSF, GM and WM)
maskidxICV = union(union(maskidxGM,maskidxWM),maskidxCSF);

%update thresholds (rough approximations based on mri-qc comparison)
maskidxGM = find(GMvol.dat(:,:,:)>0.97);
maskidxWM = find(WMvol.dat(:,:,:)>0.1);
maskidxCSF = find(CSFvol.dat(:,:,:)>0.3);

maskhdr = spm_vol_nifti(spmGMfile); % all spm segments have similar dimensions
HEADmask = zeros(maskhdr.dim);
HEADmask(maskidxHEAD)=1;

maskidxAIR = find(HEADmask==0);

%   SUMMARY STATS
%   Mean, standard deviation, 5% percentile and 95% percentile of the distribution of background, CSF, GM and WM.
voxvol = abs(maskhdr.mat(1,1))*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(3,3));
maskidx = maskidxGM;
info_GM = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),5) prctile(TargetVol.dat(maskidx),95)  kurtosis(TargetVol.dat(maskidx)) length(maskidx)*voxvol/1000];

maskidx = maskidxWM;
info_WM = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),5) prctile(TargetVol.dat(maskidx),95)  kurtosis(TargetVol.dat(maskidx)) length(maskidx)*voxvol/1000];

maskidx = maskidxCSF;
info_CSF = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),5)  prctile(TargetVol.dat(maskidx),95) kurtosis(TargetVol.dat(maskidx)) length(maskidx)*voxvol/1000];

maskidx = maskidxAIR;
info_BG = [mean(TargetVol.dat(maskidx)) std(TargetVol.dat(maskidx)) median(TargetVol.dat(maskidx)) mad(TargetVol.dat(maskidx)) ...
    prctile(TargetVol.dat(maskidx),5) prctile(TargetVol.dat(maskidx),95)  kurtosis(TargetVol.dat(maskidx)) length(maskidx)*voxvol/1000];

Summary = [info_GM info_WM info_CSF info_BG];

GMfraction = length(maskidxGM) / length(maskidxICV);
WMfraction = length(maskidxWM) / length(maskidxICV);
CSFfraction = length(maskidxCSF) / length(maskidxICV);

FRACTIONS = [GMfraction WMfraction CSFfraction];


%   CJV: %binarisation threshold 0.9 used in [Ganzetti2016]
CJV = ( mean(TargetVol.dat(find(GMvol.dat(:,:,:)>0.9))) + mean(TargetVol.dat(find(WMvol.dat(:,:,:)>0.9))) ) / ...
        abs( std(TargetVol.dat(find(GMvol.dat(:,:,:)>0.9))) - std(TargetVol.dat(find(WMvol.dat(:,:,:)>0.9))) );

%   CNR:
CNR = abs( mean(TargetVol.dat(maskidxGM)) - mean(TargetVol.dat(maskidxWM))) / ... 
      sqrt(  std(TargetVol.dat(maskidxAIR))^2 +  std(TargetVol.dat(maskidxGM))^2 + std(TargetVol.dat(maskidxWM))^2  );

%   Signal to nise ratios (SNR)
n = length(maskidxHEAD);
SNR_head = mean(TargetVol.dat(maskidxHEAD)) / std(TargetVol.dat(maskidxHEAD))*sqrt( n /(n-1));

n = length(maskidxGM);
SNR_GM = mean(TargetVol.dat(maskidxGM)) / std(TargetVol.dat(maskidxGM))*sqrt( n /(n-1));

n = length(maskidxWM);
SNR_WM = mean(TargetVol.dat(maskidxWM)) / std(TargetVol.dat(maskidxWM))*sqrt( n /(n-1));

n = length(maskidxCSF);
SNR_CSF = mean(TargetVol.dat(maskidxCSF)) / std(TargetVol.dat(maskidxCSF))*sqrt( n /(n-1));

%   SNR Dietrich: air mask here should not contain artifacts, but 
DIETRICH_FACTOR = 1.0 / sqrt(2 / (4 - pi));
SNR_dietrich_head = DIETRICH_FACTOR * mean(TargetVol.dat(maskidxHEAD)) / std(TargetVol.dat(maskidxAIR));
SNR_dietrich_GM = DIETRICH_FACTOR * mean(TargetVol.dat(maskidxGM)) / std(TargetVol.dat(maskidxAIR));
SNR_dietrich_WM = DIETRICH_FACTOR * mean(TargetVol.dat(maskidxWM)) / std(TargetVol.dat(maskidxAIR));
SNR_dietrich_CSF = DIETRICH_FACTOR * mean(TargetVol.dat(maskidxCSF)) / std(TargetVol.dat(maskidxAIR));

% if ~isempty(maskidxAIR)
%     SNR_dietrich = DIETRICH_FACTOR * mean(TargetVol.dat(maskidxHEAD)) / std(TargetVol.dat(maskidxAIR));
% else
%     disp('SNR Dietrich background mask: AIR is too small!')
% end


%FBER (Foreground to background ratio, rotation mask(?) not used here)
FBER=0;
if ~isempty(maskidxAIR) %however median might be 0
    fg_mu = median(abs(TargetVol.dat(maskidxHEAD)).^2);
    bg_mu = median(abs(TargetVol.dat(maskidxAIR)).^2);
    FBER = fg_mu / bg_mu;
%     if (bg_mu < 1.0e-3) 
%         FBER = 0;
%     else
%         
%     end
%     disp('FBER background mask: AIR is too small!')
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
WM2MAX = mean(TargetVol.dat(maskidxWM)) / prctile(TargetVol.dat(maskidxHEAD), 99.95);
%orig code: float(mu_wm / np.percentile(img.reshape(-1), 99.95))


matrix1 = {'cjv';	'cnr';	'efc';	'fber'; 'icvs_csf';	'icvs_gm';	'icvs_wm'; 'size_x';	'size_y';	'size_z';	... 
'snr_csf';	'snr_gm';	'snr_wm';	'snr_total'; 'snrd_csf';	'snrd_gm';		'snrd_wm';	'snrd_total'; 
'spacing_x'; 'spacing_y';	'spacing_z';	...
'summary_bg_mean'; 'summary_bg_stdv'; 'summary_bg_median'; 'summary_bg_mad'; 'summary_bg_p05'; 'summary_bg_p95'; 'summary_bg_k'; 'summary_bg_vol';  ...
'summary_csf_mean';'summary_csf_stdv'; 'summary_csf_median'; 'summary_csf_mad'; 'summary_csf_p05'; 'summary_csf_p95'; 'summary_csf_k'; 'summary_csf_vol';  ... 
'summary_gm_mean'; 'summary_gm_stdv';  'summary_gm_median';	'summary_gm_mad';'summary_gm_p05';	'summary_gm_p95'; 'summary_gm_k'; 'summary_gm_vol'; ...
'summary_wm_mean'; 'summary_wm_stdv'; 'summary_wm_median';	'summary_wm_mad'; 'summary_wm_p05';	'summary_wm_p95'; 'summary_wm_k'; 'summary_wm_vol';	...
			'wm2max'};

% not_yet_implemented: = {'fwhm_avg';	'fwhm_x';	'fwhm_y';	'fwhm_z'; ...
% 'inu_med';	'inu_range'; 'art_qi_1';	'art_qi_2'; ... 
% 'rpve_csf';	'rpve_gm';	'rpve_wm'; ... 
% 'tpm_overlap_csf'; 'tpm_overlap_gm';	'tpm_overlap_wm';
% };

matrix2 = [CJV; CNR; EFC; FBER; CSFfraction; GMfraction; WMfraction; maskhdr.dim(1); maskhdr.dim(2); maskhdr.dim(3); ... 
           SNR_CSF; SNR_GM; SNR_WM; SNR_head; SNR_dietrich_CSF; SNR_dietrich_GM; SNR_dietrich_WM; SNR_dietrich_head; ...
           abs(maskhdr.mat(1,1)); abs(maskhdr.mat(2,2)); abs(maskhdr.mat(3,3)); info_BG'; info_CSF'; info_GM'; info_WM'; WM2MAX ];
       
      
%write result file (csv)
fid = fopen(resultfile, 'w' );
for jj = 1 : length( matrix1 )
    fprintf( fid, '%s,%f\n', matrix1{jj}, matrix2(jj) );
end
fclose( fid );

    
end


