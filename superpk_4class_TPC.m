function [GRAYtac,WHITEtac,BLOODtac,HSBtac] = superpk_4class_TPC(seg_file,filenamedyn,frametimes,classfile)
%_______________________________________________________________________
% @(#)superpk.m		FE Turkheimer		Imperial College London
%  Supervised extraction of reference region for [11C]PK11195 dynamic studies
%  modifications: nifti read/write (spm), no background frames for data & classifier, etc. (Jouni  Tuisku, Turku PET centre)

%% Read the seg file and create the indices used in the clustering
% Exclude CSF and background voxels

V = spm_vol(seg_file);
seg_img = spm_read_vols(V);
csf_idx= [4 5 14 15 24 43 44 31 63 257 122 221];
csf_mask = ismember(seg_img,csf_idx);
background_mask = ismember(seg_img,0);
inclusion_mask = ~csf_mask & ~background_mask;
normidx = find(inclusion_mask);

%%

%=======================================================================
%				-framing input
%=======================================================================

tmid = 0.5.*(frametimes(:,1)+frametimes(:,2));
if tmid(1)<1,      % unlikely to be in seconds
    tmid = tmid(:,1).*60; %convert to seconds
end
lt = length(tmid);

%=======================================================================
%				-Calculate mean
%=======================================================================

dynhdr = spm_vol_nifti(filenamedyn);
dynvol = nifti(filenamedyn);

DYN = zeros(dynhdr.dim);

means_f = zeros(1,lt);
stds_f = zeros(1,lt);
fprintf(1,' \n Calculating frame mean values...');

for f=1:lt, %calculate mean & std framewise
    
    DYN(:,:,:) = dynvol.dat(:,:,:,f);
    means_f(f) = mean(DYN(normidx),'omitnan');
    stds_f(f)  = std(DYN(normidx),0,1,'omitnan');
    
end
clear DYN;

%=======================================================================
%				-Load Population Data
%=======================================================================

[pathstr1, ClassType] = fileparts(classfile);
str     = ['load ' classfile ' -ascii'];
eval(str);
ClassData=eval(ClassType);

[m,n]	= size(ClassData);
tref	= ClassData(:,1);
if tref(1)<1,   % unlikely to be in seconds
    tref = tref(:,1).*60; %convert to seconds
end
classcurves	= ClassData(:,2:n);

%=======================================================================
%				-Interpolate Population data
%=======================================================================
for k=lt:-1:1,
    if floor(tmid(k)) <= floor(tref(m))
        break;
    end
end
maxk	= k;
tref	= [0 tref']';
classcurves	= [zeros(n-1,1) classcurves']';
classcurvesI	= zeros(maxk,n-1);
for h=1:n-1,
    %     classcurvesI(:,h) = interp1(tref,classcurves(:,h),tmid(1:maxk));
    classcurvesI(:,h) = pchip(tref,classcurves(:,h),tmid(1:maxk));
end

DYN(:,:,:) = dynvol.dat(:,:,:,10); %ref frame
nanidx = find(isnan(DYN));
normidx = setdiff(normidx,nanidx); %fix nan problem with means

%=======================================================================
%				-FIT
%=======================================================================

DYN = zeros([dynhdr.dim lt]);
fprintf(1,' \n Normalization ...');
F	= zeros(dynhdr.dim);

for 	f=1:lt,
    
    F(:) = dynvol.dat(:,:,:,f);
    if stds_f(f)~=0, %to avoid division by zero
        F	= (F-means_f(f))/stds_f(f);
    end
    DYN(:,:,:,f) = F;
end
fprintf(1,' done.');
clear F

fprintf(1,' \n Classes Extraction: %d Planes',dynhdr.dim(3));
GRAY		= zeros(dynhdr.dim);
WHITE		= zeros(dynhdr.dim);
BLOOD		= zeros(dynhdr.dim);
HSB		    = zeros(dynhdr.dim);
MASK		= zeros(dynhdr.dim);


MASK(normidx) = 1;
v = zeros(maxk,1);
for z=1:dynhdr.dim(3),
    if (mod(z,10)==0), fprintf(1,'\n       ___Plane no. %d',z); end
    for x=1:dynhdr.dim(1),
        for y=1:dynhdr.dim(2),
            if(MASK(x,y,z)>0)
                v(:) 		= DYN(x,y,z,1:maxk);
                bv		= lsqnonneg(classcurvesI,v);
                GRAY(x,y,z) 	= bv(1);
                WHITE(x,y,z)	= bv(2);
                BLOOD(x,y,z)	= bv(3);
                HSB(x,y,z)      = bv(4);
            end
        end
    end
end

% =======================================================================
% 				-Reference Input Calculation
% =======================================================================
fprintf(1,' \n  Reference Input Calculation...');
clear DYN

GRAYtac  = zeros(lt,1);
BLOODtac = zeros(lt,1);
WHITEtac = zeros(lt,1);
HSBtac	 = zeros(lt,1);

blood_idx	= find(BLOOD>0);
gray_idx	= find(GRAY>0);
white_idx	= find(WHITE>0);
hsb_idx     = find(HSB>0);

DYN = zeros(dynhdr.dim);
for f=1:lt
    DYN(:,:,:)  = dynvol.dat(:,:,:,f);
    DYN(find(isnan(DYN)))=0;
    GRAYtac(f)	= sum(GRAY(:)'*DYN(:));
    WHITEtac(f) = sum(WHITE(:)'*DYN(:));
    BLOODtac(f) = sum(BLOOD(:)'*DYN(:));
    HSBtac(f)   = sum(HSB(:)'*DYN(:));
end

BLOODtac	= BLOODtac/sum(BLOOD(blood_idx));
GRAYtac		= GRAYtac/sum(GRAY(gray_idx));
WHITEtac	= WHITEtac/sum(WHITE(white_idx));
HSBtac		= HSBtac/sum(HSB(hsb_idx));

%=======================================================================
%				-Reference TAC plot
%=======================================================================
str		= ['Saving SCA TACs'];
disp(str);

[pathstr_dynfile, name, ext] = fileparts(filenamedyn);
namestr 	= [name '_' ClassType ];

resultsDIR = pathstr_dynfile;

maskhdr = spm_vol_nifti(seg_file);

% gray_dft  	= [resultsDIR filesep 'SCA_GRAY_' namestr '.dft'];
% roivolume= length(gray_idx)*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(3,3));
% write_dft_0_1_1(GRAYtac', frametimes, {'ref .'}, roivolume, gray_dft, name)
%
% white_dft 	= [resultsDIR filesep 'SCA_WHITE_' namestr '.dft'];
% roivolume= length(white_idx)*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(3,3));
% write_dft_0_1_1(WHITEtac', frametimes, {'whi .'}, roivolume, white_dft, name)
%
% blood_dft 	= [resultsDIR filesep 'SCA_BLOOD_' namestr '.dft'];
% roivolume= length(blood_idx)*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(3,3));
% write_dft_0_1_1(BLOODtac', frametimes, {'blo .'}, roivolume, blood_dft, name)
%
% hsb_dft 	= [resultsDIR filesep 'SCA_HSB_' namestr '.dft'];
% roivolume= length(hsb_idx)*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(1,1))*abs(maskhdr.mat(3,3));
% write_dft_0_1_1(HSBtac', frametimes, {'hsb .'}, roivolume, hsb_dft, name)



%=======================================================================
%				-saving cluster images file
%=======================================================================

% Smoothing parameters (5mm)
pixdim = abs([dynhdr.mat(1,1)  dynhdr.mat(2,2)  dynhdr.mat(3,3)]);
dimfilt		= round(11./pixdim);
filtersize = 5.0;
fwhm		= filtersize./pixdim;
sd          = fwhm/sqrt(8*log(2));

fprintf('\n Saving the cluster images .... \n');

VO = maskhdr;
VO.dt = [spm_type('int16') spm_platform('bigend')];
VO.pinfo = [Inf Inf Inf]';

cases = {'GRAY','WHITE','HSB','BLOOD'};

for c=1:length(cases)
    casename=cases{c};
    VO.descrip = 'SCA4 cluster image';
    niftiname  = [resultsDIR filesep 'SCA_' casename '_' namestr '.nii'];
    VO.fname   = niftiname;
    VO.private.dat.fname = niftiname;
    spm_write_vol(VO,eval(casename));
end

end