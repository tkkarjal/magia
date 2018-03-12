clear; clc;

restoredefaultpath;
magia_dir = '/scratch/karjalto/magia_dev/magia';
addpath(magia_dir);
addpath /scratch/shared/toolbox/spm12

dev_archive_dir = '/scratch/karjalto/magia_dev/archive';
if(~exist(dev_archive_dir,'dir'))
    mkdir(dev_archive_dir);
end
real_archive = getenv('MAGIA_ARCHIVE');
setenv('MAGIA_ARCHIVE',dev_archive_dir);

subjects = {
    'xs58' % Dynamic [11C]carfentanil (SRTM) with MRI
    'xs3' % Dynamic [11C]raclopride (SRTM) with MRI
    'xs64' % Dynamic [11C]raclopride (SRTM) without MRI
    'us1352' % Dynamic [18F]FDG (Patlak) with MRI
    'us776' % Dynamic [18F]FDG (Patlak) without MRI
    % Static late-scan [18F]FDG (FUR) with MRI
    'p100526' % Static late-scan [18F]FDG (FUR) without MRI
    'ia381' % Dynamic FDOPA scan with MRI
    'dk12354' % Imaginary study code
    };
N = length(subjects);
ME_list = cell(N,1);

parpool(6);

 parfor i = 1:N
    sub = subjects{i};
    try
        run_magia_dev(sub);
    catch ME
        ME_list{i} = ME;
    end
end

setenv('MAGIA_ARCHIVE',real_archive);

ME_list