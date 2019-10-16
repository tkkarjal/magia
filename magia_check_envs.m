function magia_check_envs()
% Checks that the required environmental variables have been specified. If
% they have not been specified, Magia throws an error message.
%
% The necessary environmental variables are:
%
% DATA_DIR:        The directory where the PET data are stored under, and where Magia will operate before archiving the results
% MRI_DIR:         The directory where the MRI data are stored under
% SPM_DIR:         The directory where SPM is installed in
% FREESURFER_HOME: The directory where FreeSurfer has been installed in
% MAGIA_PATH:      The directory containing this file as well as other Magia-code
% MAGIA_ARCHIVE:   The directory under which the Magia outputs will be stored
% FS_FINAL_DIR:    The directory under which the FreeSurfer results will be stored
% FS_TEMP_DIR:     The directory under which FreeSurfer will operate

magia_envs = {'DATA_DIR' 'MRI_DIR' 'SPM_DIR' 'FREESURFER_HOME' 'MAGIA_PATH' 'MAGIA_ARCHIVE' 'FS_FINAL_DIR' 'FS_TEMP_DIR'};
N = length(magia_envs);
env_found = true(N,1);
for i = 1:N
    env = magia_envs{i};
    if(isempty(getenv(env)))
        env_found(i) = false;
    end
end

if(any(~env_found))
    env_not_found = magia_envs(~env_found);
    M = length(env_not_found);
    if(M == 1)
        error('Magia was terminated because the environmental variable %s has not been specified. Please specify it in either startup.m or matlabrc.m using setenv, restart MATLAB, and try again.',env_not_found{1});
    else
        msg = 'Magia was terminated because the following environmental variables have not been specified:';
        for i = 1:M
            msg = sprintf('%s %s',msg,env_not_found{i});
        end
        error('%s\nPlease specify the environmental variables in either startup.m or matlabrc.m using setenv, restart MATLAB, and try again.',msg);
    end
end

end