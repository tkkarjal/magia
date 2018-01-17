function im = PSVsmooth_3d(im,sd,l)

%

%  PSVSMOOTH_3D.M

%  Application of a Gaussian filter in 3d

%  usage:       	im =PSVsmooth_3d(im,sd,l)

%  Inputs:

%	im		    3d image 

%	sd	        standard deviation vector [sdx sdy sdz]

%        l           length vector [lx ly lz]

%  Output:

%	im		    filtered image

[xdim,ydim,zdim]    =size(im);

PSFx                =normpdf(0:1:l(1),0,sd(1));

PSFy                =normpdf(0:1:l(2),0,sd(2));

PSFz                =normpdf(0:1:l(3),0,sd(3));

Px =toeplitz([PSFx zeros(1,xdim-length(PSFx))]);
Py =toeplitz([PSFy zeros(1,ydim-length(PSFy))]);

Pz =toeplitz([PSFz zeros(1,zdim-length(PSFz))]);

for x=1:size(im,3);im(:,:,x)=Px*squeeze(im(:,:,x));end

for y=1:size(im,1);im(y,:,:)=Py*squeeze(im(y,:,:));end

for z=1:size(im,2);im(:,z,:)=squeeze(im(:,z,:))*Pz;end


end