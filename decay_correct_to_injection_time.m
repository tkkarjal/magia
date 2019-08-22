function decay_correct_to_injection_time(uncorrected_pet_image,frames,tracer)
%
% frames contains times since injection

if(~ismatrix(frames))
    error('Could not decay-correct the image %s because the frames-variable was poorly specified. The frames-variable should be a matrix.\n',uncorrected_pet_image);
end

odir = fileparts(uncorrected_pet_image);
V = spm_vol(uncorrected_pet_image);
N = size(V,1);
Vo = spm_file_split(V, odir);

switch tracer
    case {'[11c]carfentanil','[11c]raclopride','[11c]pib'}
        half_life = 20.4; % minutes
    case {'[18f]fdg','[18f]spa-rq','[18f]fmpep-d2'}
        half_life = 109.8; % minutes
    otherwise
        error;
end

lambda = log(2)/half_life;
scaling_factor = exp(lambda*frames(1,1));

for i = 1:N
    uncorrected_image = spm_read_vols(Vo(i));
    decay_corrected_image = scaling_factor*uncorrected_image;
    spm_write_vol(Vo(i),decay_corrected_image);
end

spm_file_merge(Vo,uncorrected_pet_image,0);

for i = 1:N
    delete(Vo(i).fname);
end

end