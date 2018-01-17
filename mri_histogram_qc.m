function mri_histogram_qc(subject,mri)

V = spm_vol(mri);
image = spm_read_vols(V);

gmi = add_prefix(mri,'c1');
V = spm_vol(gmi);
gm_image = spm_read_vols(V);

wmi = add_prefix(mri,'c2');
V = spm_vol(wmi);
wm_image = spm_read_vols(V);
clear V

gm_mask = gm_image > 0.5;
wm_mask = wm_image > 0.5;

gm_vals = image(gm_mask);
wm_vals = image(wm_mask);
all_vals = [gm_vals;wm_vals];
[~,x] = hist(all_vals,100);

n_gm = hist(gm_vals,x);
n_wm = hist(wm_vals,x);

GM = fit_gaussian_mixture(all_vals,2);

fig = figure('Position',[800 645 834 481],'Visible','Off'); clf;
bar(x,n_gm,'b','grouped'); hold on; bar(x,n_wm,'r'); hold on;
h = legend('GM','WM'); h.Box = 'off';
xlabel('MR signal intensity (a.u.)');
ylabel('Counts');
title('Brain MRI histogram');

mu = GM.mu;
s = sqrt(squeeze(GM.Sigma));
w = GM.ComponentProportion;

y = w(1)*normpdf(x,mu(1),s(1)) + w(2)*normpdf(x,mu(2),s(2));
y = (y/max(y))*max([n_gm n_wm]);
plot(x,y,'k','LineWidth',2);

l1 = sprintf('\\mu_G_M = %.2f',min(mu));
l2 = sprintf('\\mu_W_M = %.2f',max(mu));
l3 = sprintf('\\Delta\\mu = %.2f (%.2f %%)',max(mu)-min(mu),100*(max(mu)-min(mu))/min(mu));

text(x(end-20),prctile(y,70),{l1;l2;l3});

add_to_qc_pic(subject,fig)
close(fig);

end
