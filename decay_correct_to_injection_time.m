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

isotope_idx = regexp(tracer,']');
switch tracer(1:isotope_idx)
    case {'[11c]'}, half_life = 20.4; % minutes
    case {'[18f]'}, half_life = 109.8; % minutes
    case {'[15o]'}, half_life = 2.05; % minutes
    case {'[13n]'}, half_life = 9.98;
    case {'[62cu]'}, half_life = 9.7;
    case {'[64cu]'}, half_life = 762.018;
    case {'[68ga]'}, half_life = 68.0;
    case {'[68ge]'}, half_life = 396000;
    case {'[76br]'}, half_life = 978;
    case {'[82rb]'}, half_life = 1.25;
    case {'[89zr]'}, half_life = 78.4;
    case {'[124i]'}, half_life = 100.224;

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