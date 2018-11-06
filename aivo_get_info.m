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
patient_cols = columns(conn,'megapet','aivo','patient');
model_cols = columns(conn,'megapet','aivo','model');
blood_cols = columns(conn,'megapet','aivo','blood');
if(ismember(field,pet_cols))
    tab = 'pet';
elseif(ismember(field,patient_cols))
    tab = 'patient';
elseif(ismember(field,model_cols))
    tab = 'model';
elseif(ismember(field,blood_cols))
    tab = 'blood';
else
    error('Unrecognized field name: %s',field);
end

%% Pre-sort list and compute indeces for unsorting

unsorted_list=subject_id;

[subject_id,~]=sort(unsorted_list);

[~,unsorting_idx]=sort(sorting_idx);

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
    case {'age' 'dose' 'weight' 'height' 'freesurfed' 'validated' 'analyzed' 'found' 'mri_found' 'plasma' 'dc' 'rc' 'ap' 'ab' 'vp' 'vb' 'hct' 'use_mri' 'num_frames' 'start_time' 'nii' 'cut_time'}
        value = cell2mat(value);
end

if(~ischar(subject_id))
    if(length(value) ~= N)
        warning('The number of values obtained differs from the number of subject_ids.');
        %Resorting with the original order and performing running main function in loop
        subject_id=unsorted_list;
        for i=1:length(subject_id)

        try
        
        disp(['Proceeding with ' num2str(i) ' out of ' num2str(length(subject_id))])    
            
        value(i) = aivo_get_info(subject_id{i},field);
        
        catch
        
        warning(['Error with ' subject_id{i}])
        res(i) = [NaN];
        
        end

    else
    
        value=value(unsorting_idx);

    end
end

end
