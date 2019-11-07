function value = aivo_get_info(subjects,field)
% Read data from AIVO.
%
% Inputs:
% subject_id = a cell array defining the image_ids whose
%              information you want to read from AIVO
% field = a char defining the field that you want to read
%
% Outputs:
% value = a cell or a numerical array with the obtained values
%
% Currently AIVO consists of two main tables: study and magia. In order to
% see the fields in the study table, first open up a connection to AIVO using
% conn = aivo_connect, and then
% study_cols columns(conn,'megapet','aivo2','study')
% In order to see the fields in the magia table, first open up a connection
% to AIVO and then
% magia_cols = columns(conn,'megapet','aivo2','magia')

conn = aivo_connect();

study_cols = columns(conn,'megapet','aivo2','study');
patient_cols = columns(conn,'megapet','aivo2','patient');
magia_cols = columns(conn,'megapet','aivo2','magia');
lab_cols = columns(conn,'megapet','aivo2','lab');
inventory_cols = columns(conn,'megapet','aivo2','inventory');

if(ismember(field,study_cols))
    tab = 'study';
elseif(ismember(field,patient_cols))
    tab = 'patient';
elseif(ismember(field,magia_cols))
    tab = 'magia';
elseif(ismember(field,lab_cols))
    tab = 'lab';
elseif(ismember(field,inventory_cols))
    tab = 'inventory';
else
    error('Unrecognized field name: %s',field);
end

if(ischar(subjects))
    subjects = {subjects};
end

[sorted_subjects,sort_idx] = sort(subjects);

found = aivo_check_found(sorted_subjects,tab);
found_subjects = sorted_subjects(found);

select_statement = sprintf('SELECT %s.%s FROM "megabase"."aivo2".%s',tab,lower(field),tab);
N = length(found_subjects);

if(N)
    for i = 1:N
        if(i == 1)
            where_statement = sprintf('WHERE %s.image_id = ''%s''',tab,lower(found_subjects{1}));
        else
            where_statement = sprintf('%s OR %s.image_id = ''%s''',where_statement,tab,lower(found_subjects{i}));
        end
    end
    q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);
    curs = exec(conn,q);
    curs = fetch(curs);
    value = curs.Data;
    close(curs);
end

close(conn);

switch field
    case {'age' 'dose' 'weight' 'height' 'freesurfed' 'analyzed' 'found' 'mri_found' 'plasma' 'dc' 'rc' 'hct' 'cut_time' 'fwhm_pre' 'fwhm_post' 'fwhm_roi' 'cpi' 'glucose' 'gu'}
        numeric = 1;
    otherwise
        numeric = 0;
end

if(~all(found))
    if(numeric)
        value_corrected = nan(size(subjects));
    else
        value_corrected = cell(size(subjects));
    end
    if(N)
        if(numeric)
            value = cell2mat(value);
        end
        value_corrected(found) = value;
    end
    value = value_corrected;
    warning('Could not find a value for every requested subject. Please make sure the image_ids are not misspelled');
end

value = value(sort_idx);

end