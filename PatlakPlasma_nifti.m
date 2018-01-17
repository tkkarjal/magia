function parametric_images = PatlakPlasma_nifti(plasmadata,startTime,cutFrame,frametimes,filenamedyn,brainmask_file,outputdir)

V = spm_vol(filenamedyn);
img = spm_read_vols(V);
max_img = max(img(:));
max_input = max(plasmadata(:,2));

if(max_img < 500 && max_input > 500)
    plasmadata(:,2) = 0.001.*plasmadata(:,2);
elseif(max_img > 500 && max_input < 500)
    plasmadata(:,2) = 1000.*plasmadata(:,2);
end

tol = 1.0e-6; %tolerance for numerical integration
if(cutFrame==0)
    cutFrame = size(frametimes,1);
end
beginFrame = frametimes(1:cutFrame,1);
endFrame = frametimes(1:cutFrame,2);
tmid = (beginFrame  + endFrame ) / 2;
frameDur = endFrame - beginFrame; 
evalT = tmid;  

dynhdr = spm_vol_nifti(filenamedyn);
dynVol = nifti(filenamedyn);
nFrames = cutFrame;

V = spm_vol(brainmask_file);
MASK = V.private.dat(:,:,:);
 
%interpolate plasma data
idx=find(plasmadata(:,1)<=frametimes(cutFrame,2),1,'last'); 
plasmaCurve = pchip(plasmadata(1:idx,1),plasmadata(1:idx,2));  
adapterFunction = @(t, funH, parm, varargin) funH(parm, t, varargin{:});

runningIntCp = zeros(nFrames, 1);
for i = 1:nFrames,
    runningIntCp(i) = quad(adapterFunction, 0, evalT(i), tol, [], @ppval, plasmaCurve);
end   
Cp = ppval(plasmaCurve, evalT);

Ki_img_3D =zeros(size(MASK));
Intercept_img_3D = Ki_img_3D;

DYNplane = zeros([dynVol.dat.dim(1) dynVol.dat.dim(2) nFrames]); %dynVol.dat.dim(4)
fprintf(1,'\nStarting to fit Patlak. \n');

k = find( (endFrame > startTime) );
if (length(k) < 2),
    warning('Cannot fit data with less than two data points.  NaN will be returned. Error occurred with %s.',filenamedyn)
end

for pl = 1:dynVol.dat.dim(3)

    if (mod(pl,10)==0), disp(['fitting plane: ' int2str(pl)]); end;

    DYNplane(:,:,:) = dynVol.dat(:,:,pl,1:nFrames);

    %process all TACs from the corresponding plane in one go
    [mask_iX,mask_iY] = find(MASK(:,:,pl)); 
    
    if length(mask_iX>0)

        TACs= zeros(nFrames,length(mask_iX));
        nTACs = length(mask_iX); 

        for T = 1:nTACs   
            CPET= DYNplane(mask_iX(T), mask_iY(T),:); 
            TACs(:,T)=CPET(:);
        end
        TACs(isnan(TACs)) = 0 ;   %replace NaNs with zeros

        pp = pchip(tmid(1:nFrames), TACs'); % maybe unnecessary?
        Ct = ppval(pp, evalT); 
        if (pp.dim > 1), 
            Ct = Ct.';
        end

        y = Ct ./ repmat(Cp, [1 nTACs]);
        A=[runningIntCp ./ Cp  ones([nFrames 1])];
             
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
parametric_images{1} = fullfile(outputdir,[filename '_Patlak_Ki' '.nii']);
parametric_images{2} = fullfile(outputdir,[filename '_Patlak_intercept' '.nii']);

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
