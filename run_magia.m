function run_magia(subject,varargin)
%% An interface between magia_processor and metadata specifications
%
% In Turku PET Centre, the study specs are stored in AIVO, a centralized
% database containing metadata from approximately 16 000 brain PET studies.
% If only one input argument is given, run_magia tries to read the metadata
% from AIVO. Otherwise, three input arguments must be given.
%
% The first input argument defines a subject id. The function assumes that
% a folder with exactly the same name exists under getenv('DATA_DIR').
% Please see the wiki page for information about the assumed folder
% structre.
%
% The second input argument defines the study and processing
% specifications.
%
% The third input argument defines the modeling options.

%% First read metadata

if(nargin == 1) % Read MAGIA processing options and modeling options from AIVO
    aivo = 1;
    found = aivo_check_found(subject,'study');
    if(found)
        try
            specs = aivo_read_magia_specs(subject);
            modeling_options = aivo_read_modeling_options(subject);
        catch ME
            error_message = aivo_parse_me(ME);
            aivo_set_info(subject,'error',error_message);
            rethrow(ME);
        end
    else
        error('Could not magia %s because the image_id does not exist in AIVO.',subject);
    end
elseif(nargin == 3) % MAGIA processing options and modeling options given as extra input arguments
    aivo = 0;
    specs = varargin{1};
    modeling_options = varargin{2};
else
    error('Wrong number of input arguments. Please see help run_magia for more information.');
end

specs = magia_replace_empty_specs_with_defaults(specs);
magia_check_specs(specs);

%% Run MAGIA

try
    magia_processor(subject,specs,modeling_options);
    magia_archive_results(subject,specs.magia);
    magia_clean_files(subject);
    if(aivo)
        aivo_store_magia_info(subject,specs);
    end
catch ME
    if(aivo)
        error_message = aivo_parse_me(ME);
        aivo_set_info(subject,'error',error_message);
    end
    rethrow(ME);
end

end
