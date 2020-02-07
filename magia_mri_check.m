function [msg] = magia_mri_check(list)

% Runs magia_get_mri_file on a list of image_id to verify that the MRI (T1)
% is valid for analysis

msg = list;

for i=1:length(list)

    try

        mri_code=aivo_get_info(list{i},'mri_code');
        magia_get_mri_file(list{i},mri_code{1});
        msg{i,2}= 'MRI valid for analysis';

    catch

        msg{i,2}= 'ERROR: MRI not valid for analysis. Redownload necessary!';

    end

end
    