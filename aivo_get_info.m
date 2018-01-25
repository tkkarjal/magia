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
% Currently AIVO consists of two main tables: pet and model. In order to
% see the fields in the pet table, first open up a connection to AIVO using
% conn = aivo_connect, and then
% pet_cols columns(conn,'megapet','aivo','pet')
% In order to see the fields in the model table, first open up a connection
% to AIVO and then
% model_cols = columns(conn,'megapet','aivo','model')

conn = aivo_connect();

pet_cols = columns(conn,'megapet','aivo','pet');
model_cols = columns(conn,'megapet','aivo','model');
blood_cols = columns(conn,'megapet','aivo','blood');
if(ismember(field,pet_cols))
    tab = 'pet';
elseif(ismember(field,model_cols))
    tab = 'model';
elseif(ismember(field,blood_cols))
    tab = 'blood';
else
    error('Unrecognized field name: %s',field);
end

select_statement = sprintf('SELECT %s.%s FROM "megabase"."aivo".%s',tab,lower(field),tab);
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
    case {'dose' 'weight' 'height' 'freesurfed' 'validated' 'analyzed' 'found' 'plasma' 'dc' 'rc' 'ap' 'ab' 'vp' 'vb' 'hct' 'use_mri' 'num_frames' 'start_time'}
        value = cell2mat(value);
end

if(~ischar(subject_id))
    if(length(value) ~= N)
        warning('The number of values obtained differs from the number of subject_ids.');
    end
end

end