function [value,subject_id_ori] = aivo_get_info(subject_id,field)
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

%Sort alphabetically the subject list and store indeces

if iscell(subject_id) && length(subject_id) > 1 % more than one subject
    
    if iscellstr(subject_id)
        subject_id_ori=subject_id;
        [subject_id,sort_idx_temp]=sort(subject_id);
    elseif iscell(subject_id)  % Handles lists copied and pasted from Excel in a cell array not of characters. 
        subject_id_ori=string(subject_id); % Sort requires a change from string() first
        [subject_id,sort_idx_temp]=sort(string(subject_id));
    else
        help aivo_get_info;
        error('Input subject list not valid!');
    end
    
    [~,sort_idx] = sort(sort_idx_temp); % Get indexes to revert to the original sorting
    
end

conn = aivo_connect();

refresh(conn)

materia_cols = columns(conn,'megapet','aivo2','materia');
study_code_cols = columns(conn,'megapet','aivo2','study_code'); % Should be added in materia from Janne

%if(~ismember(field,cols))
%    error('Unrecognized field name: %s',field);
%end

if(ismember(field,materia_cols))
    tab = 'materia';
elseif(ismember(field,study_code_cols))
    tab = 'study_code';
else
    error('Unrecognized field name: %s',field);
end


if(ischar(subject_id))
    subject_id = {subject_id};
end

%[sorted_subjects,sort_idx] = sort(subject_id); Wrong. Sorting happens
%earlier

found = aivo_check_found(subject_id,tab);
found_subjects = subject_id(found);

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
    case {'age' 'dose' 'weight' 'height' 'freesurfed' 'analyzed' 'found' 'mri_found' 'dc' 'rc' 'hct' 'cut_time' 'fwhm_pre' 'fwhm_post' 'fwhm_roi' 'cpi' 'glucose' 'gu'}
        numeric = 1;
    otherwise
        numeric = 0;
end

if(~all(found))
    if(numeric)
        value_corrected = nan(size(subject_id));
    else
        value_corrected = cell(size(subject_id));
    end
    if(N)
        if(numeric)
            value = cell2mat(value);
        end
        value_corrected(found) = value;
    end
    value = value_corrected;
    warning('Could not find a value for every requested subject. Please make sure the image_ids are not misspelled');
else
    if(numeric)
        value = cell2mat(value);
    end
end

if numel(value) > 1 % Resort only if more than one subjects where queried
value = value(sort_idx);
end

end

function refresh(conn)

refresh_cmd = 'REFRESH MATERIALIZED VIEW aivo2.materia';
curs = exec(conn,refresh_cmd);
close(curs);

end
