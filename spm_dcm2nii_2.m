function nii_fnames = spm_dcm2nii_2(dicom_path,nii_path)

f = spm_select('FPList',dicom_path,'.dcm');
if(isempty(f))
    f = spm_select('FPList',dicom_path,'.*');
end
N = size(f,1);
fprintf('Reading headers of %.0f dicom files...\n',N);
hdr_list = spm_dicom_headers(f);
fprintf('Converting the dicoms into nifti format...\n');
P = spm_dicom_convert(hdr_list,'all','flat','nii',nii_path);
nii_fnames = P.files;

cellfun(@force_ras,nii_fnames);

end