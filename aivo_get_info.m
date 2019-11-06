function value = aivo_get_info(subject_id,field)
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
        [subject_id]=sort(subject_id);
    elseif iscell(subject_id)  % Handles lists copied and pasted from Excel in a cell array not of characters. 
        subject_id_ori=string(subject_id); % Sort requires a change from string() first
        [subject_id]=sort(string(subject_id));
    else
        help aivo_get_info;
        error('Input subject list not valid!');
    end
    
end

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

select_statement = sprintf('SELECT %s.%s FROM "megabase"."aivo2".%s',tab,lower(field),tab);
if(ischar(subject_id))
    where_statement = sprintf('WHERE %s.image_id = %s%s%s',tab,char(39),lower(subject_id),char(39));
else
    N = length(subject_id);
    where_statement = sprintf('WHERE %s.image_id = %s%s%s',tab,char(39),lower(subject_id{1}),char(39));
    for i = 2:N
        where_statement = sprintf('%s OR %s.image_id = %s%s%s',where_statement,tab,char(39),lower(subject_id{i}),char(39));
    end
end

q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);

curs = exec(conn,q);
curs = fetch(curs);
close(curs);
value = curs.Data;
close(conn);

switch field
    case {'age' 'dose' 'weight' 'height' 'freesurfed' 'analyzed' 'found' 'mri_found' 'plasma' 'dc' 'rc' 'hct' 'cut_time' 'fwhm_pre' 'fwhm_post' 'fwhm_roi' 'cpi' 'glucose' 'gu'}
        numeric = 1; % For handling no data
        value = cell2mat(value);
end

if(~ischar(subject_id))
    if(length(value) ~= N)
        warning('The number of values obtained differs from the number of subject_ids. Switching to loop mode');
        %Resorting with the original order
        subject_id=subject_id_ori;
        for i=1:length(subject_id)

            try

                disp(['Proceeding with ' num2str(i) ' out of ' num2str(length(subject_id))])    

                if numeric == 1

                    value(i) = aivo_get_info(subject_id{i},field);

                else

                    value(i) = {aivo_get_info(subject_id{i},field)};

                end

            catch

                warning(['Error with ' subject_id{i}])

                if numeric == 1

                    value(i) = [];

                else

                    value(i) = {};

                end

            end
        
        end
        
    else % Retreived as many values as subjects
        
        [~,~,idx] = intersect(subject_id_ori,subject_id,'stable');
        value = value(idx);
        
    end
end

end