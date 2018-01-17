function spm_write_4d_nifti(V,img,filename)

if(size(V,1)~=size(img,4))
    error('The number of image headers has to be the same as the number of time points in the image file.\n');
end

N = length(V);
static_filenames = cell(N,1);

for i = 1:N
    W = V(i);
    W.n = [1 1];
    if(i<10)
        postfix = sprintf('_0%.0f',i);
    else
        postfix = sprintf('_%.0f',i);
    end
    W.fname = add_postfix(W.fname,postfix);
    spm_write_vol(W,squeeze(img(:,:,:,i)));
    static_filenames{i} = W.fname;
end

spm_nifti_dynamize(static_filenames,filename)

end