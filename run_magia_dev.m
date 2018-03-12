function run_magia_dev(subject,varargin)
%% An interface between magia_processor and metadata specifications
%
% MAGIA processes a brain PET study with standardized methods. The
% processing method depends on the tracer, whether the study is dynamic or
% static, whether an MRI is available for FreeSurfing, and whether plasma
% input is available for modeling.
%
% In Turku PET Centre, such metadata are stored in AIVO, a centralized
% database containing metadata from approximately 16 000 brain PET studies.
% If only one input argument is given, run_magia tries to read the metadata
% from AIVO. Otherwise, three input arguments must be given.
%
% The first input argument defines a subject id. The function assumes that
% a folder with exactly the same name exists under getenv('DATA_DIR').
% Please see the wiki page for information about the assumed folder
% structre.

%% First read metadata

if(nargin == 1) % Read MAGIA processing options and modeling options from AIVO
    aivo = 1;
    found = aivo_check_found(subject);
    if(found)
        [I, modeling_options] = magia_metadata_from_aivo(subject);
    else
        error('Could not magia %s because the image_id does not exist in AIVO.',subject);
    end
elseif(nargin == 3) % MAGIA processing options and modeling options given as extra input arguments
    aivo = 0;
    I = varargin{1};
    modeling_options = varargin{2};
else
    error('Wrong number of input arguments. Please see help run_magia for more information.');
end

%% Run MAGIA

try
    magia_processor(subject,I,modeling_options);
    magia_archive_results(subject);
    magia_clean_files(subject);
    if(aivo)
        aivo_store_magia_info(subject);
    end
catch ME
    if(aivo)
        error_message = aivo_parse_me(ME);
        aivo_set_info(subject,'error',error_message);
    end
    rethrow(ME);
end

end