function [corrected_reference_region,thr] = data_driven_reference_region_correction_fwhm(uncorrected_reference_region,mean_pet_image,varargin)

[~,n,e] = fileparts(uncorrected_reference_region);
V = spm_vol(uncorrected_reference_region);
uncorrected_reference_region = logical(spm_read_vols(V));

if(ischar(mean_pet_image))
    W = spm_vol(mean_pet_image);
    mean_pet_image = spm_read_vols(W);
    clear W;
end

v = mean_pet_image(uncorrected_reference_region);
v = v(logical(v>prctile(v,1)));
n_bins = floor(length(v)/18);
N = hist(v,n_bins);
[f,xi] = ksdensity(v);
[f_max,max_idx] = max(f);
f_thr = f_max/2;
mode = xi(max_idx);

idx = f >= f_thr;
xi_selected = xi(idx);

ll = min(xi_selected);
ul = max(xi_selected);

dl = mode - ll;
du = ul - mode;

dd = min([dl du]);
ll = mode - dd;
ul = mode + dd;
thr = ll;

fig = figure('Visible','Off'); hist(v,n_bins); hold on; plot(xi,max(N)/max(f)*f,'r');
plot([ll ll],[0 max(N)],'k--','LineWidth',1.5);
plot([ul ul],[0 max(N)],'k--','LineWidth',1.5);
plot(xi,max(N)/max(f)*f_thr.*ones(size(xi)),'k--','LineWidth',1.5);

corrected_reference_region = uint8(mean_pet_image>ll) .* uint8(mean_pet_image<ul) .* uint8(uncorrected_reference_region);
n = [n '_dc'];
if(nargin==2)
    V.fname = add_postfix(V.fname,'_dc');
else
    outdir = varargin{1};
    if(~exist(outdir,'dir'))
        mkdir(outdir);
    end
    V.fname = fullfile(outdir,[n e]);
end

V.descrip = sprintf('ll = %.0f; ul = %.0f',ll,ul);
spm_write_vol(V,corrected_reference_region);
corrected_reference_region = V.fname;
p = fileparts(V.fname);

idx = regexp(p,'/');
subject = p(idx(end-1)+1:idx(end)-1);
add_to_qc_pic(subject,fig);

close(fig);

end
