function W = cg_set_com_mod(imagefile)
% use center-of-mass (COM) to roughly correct for differences in the
% position between image and template
% does not actually change the origo, but changes the affine transformation
% so that after the translation the

% pre-estimated COM of MNI template
com_reference = [0 -20 -5];

V = spm_vol(imagefile);

%fprintf('Correct center-of-mass for %s\n',V.fname);
Affine = eye(4);
vol = spm_read_vols(V);
avg = mean(vol(:));
avg = mean(vol(find(vol>avg)));

% don't use background values
[x,y,z] = ind2sub(size(vol),find(vol>avg));
com = V.mat(1:3,:)*[mean(x) mean(y) mean(z) 1]';
com = com';

M = spm_get_space(V.fname);
Affine(1:3,4) = (com - com_reference)';
W = Affine\M;
V.descrip = 'centered';
spm_get_space(V.fname,W);

end