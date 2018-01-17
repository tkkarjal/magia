function parametric_images = PatlakRef_nifti(refdata,startTime,cutTime,frametimes,filenamedyn,filtersize,brainmask_file,outputdir) 
    
tol = 1.0e-6; %tolerance for numerical integration

midFrame = (frametimes(:,1)  + frametimes(:,2) ) / 2;
tmid=midFrame;
evalT = midFrame;  % values T in the regression equation
frameDur(1,1)= midFrame(1);
for k=2:length(midFrame)
    frameDur(k,1) = midFrame(k)-midFrame(k-1);
end

refdata = [tmid refdata];

dynhdr = spm_vol_nifti(filenamedyn);
dynVol = nifti(filenamedyn);
nFrames = dynhdr.private.dat.dim(4);

if nFrames ~= length(tmid)
    error(['Number of frame times ' num2str(length(tmid)) ... 
    ' does not match number of dynamic frames in image '  ...
    num2str(dynhdr.private.dat.dim(4))])
end

dynhdr = spm_vol_nifti(filenamedyn);
DYN1 = zeros(dynhdr.dim);
dynVol = nifti(filenamedyn);

pixdim = abs([dynhdr.mat(1,1)  dynhdr.mat(2,2)  dynhdr.mat(3,3)]);
dimfilt		= round(11./pixdim);
fwhm		= filtersize./pixdim;
sd          = fwhm/sqrt(8*log(2));

%mask using summed PET

DYN = zeros([dynhdr.dim nFrames]);
SUMI = zeros(dynhdr.dim);
F	= zeros(dynhdr.dim);
for f=1:nFrames,
    DYN1(:,:,:) = dynVol.dat(:,:,:,f);
    F(:)	= DYN1(:,:,:);
    SUMI	= SUMI+F*frameDur(f);
    if(filtersize>0)
        DYN1(:,:,:) = PSVsmooth_3d(DYN1(:,:,:),sd,dimfilt);
        F(:) = DYN1(:,:,:);
    end
    DYN(:,:,:,f) = F;
    
end
clear DYN1
clear F

%  mSUMI	= mean(SUMI(:),'omitnan');
%  thrs = 1;
%  memoidx	= find(SUMI>=thrs*mSUMI);
%  MASK	= zeros(dynhdr.dim);
%  MASK(memoidx)	= 1;

 V = spm_vol(brainmask_file);
 MASK = spm_read_vols(V);
 
%interpolate plasma data
refCurve = pchip([0 ; refdata(:,1)],[0 ; refdata(:,2)] );
refvalues = ppval(refCurve,tmid); 
adapterFunction = @(t, funH, parm, varargin) funH(parm, t, varargin{:});

runningIntRef = zeros(nFrames, 1);
for i = 1:nFrames
    runningIntRef(i)  = quad(adapterFunction, 0, evalT(i), tol, [], @ppval, refCurve);  
%     runningIntRef(i)  = trapz([0 ; tmid(1:i)],[0; refvalues(1:i)]); %makes no difference
end   
 
Ki_img_3D = zeros(dynhdr.dim);
Intercept_img_3D =zeros(dynhdr.dim);

% DYNplane = zeros([dynVol.dat.dim(1) dynVol.dat.dim(2) dynVol.dat.dim(4)]);
fprintf(1,'\nStarting to fit Patlak with reference input. \n');

if(~cutTime)
    cutTime = frametimes(end,2);
end

k1 = find(frametimes(:,1) >= startTime);
k2 = find(frametimes(:,2) <= cutTime);
k = intersect(k1,k2);

if (length(k) < 2)
    warning('Cannot fit data with less than two data points.  NaN will be returned.')
end
 
A = [runningIntRef ./ refvalues    ones([nFrames 1]) ];

for pl = 1:dynVol.dat.dim(3)

    if (mod(pl,10)==0), disp(['fitting plane: ' int2str(pl)]); end;
    
    %process all TACs from the corresponding plane in one go
    [mask_iX mask_iY] = find(MASK(:,:,pl)); 
    
    if length(mask_iX>0)

        TACs= zeros(nFrames,length(mask_iX));
        nTACs = length(mask_iX); 

        for T = 1:nTACs   
            CPET= DYN(mask_iX(T), mask_iY(T),pl,:);
            TACs(:,T)=CPET(:);
        end
        TACs(isnan(TACs)) = 0 ;   %replace NaNs with zeros

        pp = pchip(tmid, TACs');
        Ct = ppval(pp, evalT); 
        if (pp.dim > 1), 
            Ct = Ct.';
        end
%                    
        y = Ct./repmat(refvalues, [1 nTACs]);

        Ki = zeros([1 nTACs]);
        intercept = zeros([1 nTACs]);

        % oridinary regression: (faster this way)                      
        x = A(k,:) \ y(k,:);  
        Ki = x(1,:);
        intercept = x(2,:);           

        for T=1:length(mask_iX),
            Ki_img_3D(mask_iX(T),mask_iY(T),pl)   = Ki(T);            
            Intercept_img_3D(mask_iX(T),mask_iY(T),pl) = intercept(T);
        end

    end
   
end

[~,filename] = fileparts(filenamedyn);

parametric_images = cell(2,1);
parametric_images{1} = fullfile(outputdir,[filename '_Patlak_ref_Ki' '.nii']);
parametric_images{2} = fullfile(outputdir,[filename '_Patlak_ref_intercept' '.nii']);

V.dt = [spm_type('int16') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';

niftiname = parametric_images{1};
V.fname = niftiname;
V.private.dat.fname = niftiname; 
spm_write_vol(V,Ki_img_3D);

niftiname = parametric_images{2};
V.fname = niftiname;
V.private.dat.fname = niftiname;  
spm_write_vol(V,Intercept_img_3D);

end