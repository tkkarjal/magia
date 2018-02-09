function subjects = aivo_get_subjects_dev(varargin)

%% Read input arguments

ncriteria = nargin/2;
fields = varargin(1:2:end);
values = varargin(2:2:end);

%% Read column names of the AIVO tables

conn = aivo_connect();

table_list = {
    'pet'
    'model'
    };
T = length(table_list);
cols_list = cell(T,1);
for t = 1:T
    cols_list{t} = columns(conn,'megapet','aivo',table_list{t});
end

%% Associate each input field with a table

table_nums = zeros(ncriteria,1);

for i = 1:ncriteria
    field = fields{i};
    for t = 1:T
        if(ismember(field,cols_list{t}))
            table_nums(i) = t;
            break;
        end
    end
end

%% Rearrange the query arguments

[sorted_table_nums,sort_idx] = sort(table_nums);
fields = fields(sort_idx);
values = values(sort_idx);

table_nums_needed = unique(table_nums);
M = length(table_nums_needed);
Q = cell(M,1);

for i = 1:M
    idx = sorted_table_nums == table_nums_needed(i);
    K = sum(idx);
    Q{i} = cell(K,2);
    Q{i}(:,1) = fields(idx);
    Q{i}(:,2) = values(idx);
end

%% Run the queries

S = cell(M,1);

for i = 1:M
    tb = table_list{table_nums_needed(i)};
    select_statement = sprintf('SELECT %s.image_id FROM megabase.aivo.%s',tb,tb);
    where_statement = 'WHERE';
    nc = size(Q{i},1);
    for j = 1:nc
        field = lower(Q{i}{j,1});
        value = Q{i}{j,2};
        switch field
            case {'project' 'tracer' 'gender' 'scanner' 'mri' 'injection_time' 'group_name' 'description' 'type' 'source' 'notes' 'error' 'githash' 'roi_set' 'model'}
                if(j == 1)
                    if(~strcmp('~',value(1)))
                        where_statement = sprintf('%s %s.%s = ''%s''',where_statement,tb,field,value);
                    else
                        value = value(2:end);
                        where_statement = sprintf('%s NOT %s.%s = ''%s''',where_statement,tb,field,value);
                    end
                else
                    if(~strcmp('~',value(1)))
                        where_statement = sprintf('%s AND %s.%s = ''%s''',where_statement,tb,field,value);
                    else
                        value = value(2:end);
                        where_statement = sprintf('%s NOT AND %s.%s = ''%s''',where_statement,tb,field,value);
                    end
                end
            case {'dc' 'freesurfed' 'found' 'analyzed' 'validated' 'dynamic' 'aivo_project' 'queried' 'nii' 'rc' 'use_mri'}
                if(j == 1)
                    if(~strcmp('~',value(1)))
                        where_statement = sprintf('%s %s.%s = %d',where_statement,tb,field,value);
                    else
                        value = value(2:end);
                        where_statement = sprintf('%s NOT %s.%s = %d',where_statement,tb,field,value);
                    end
                else
                    if(~strcmp('~',value(1)))
                        where_statement = sprintf('%s AND %s.%s = %d',where_statement,tb,field,value);
                    else
                        value = value(2:end);
                        where_statement = sprintf('%s NOT AND %s.%s = %d',where_statement,tb,field,value);
                    end
                end
            otherwise
                error('Subject query cannot use fields that represent continues values (e.g. age, weight, height) at the moment.');
        end
    end
    q = [select_statement ' ' where_statement,'ORDER BY image_id ASC;'];
    curs = exec(conn,q);
    curs = fetch(curs);
    close(curs);
    if(strcmp(curs.Data{1},'No Data'))
        S{i} = [];
    else
        S{i} = curs.Data;
    end
end

close(conn);

%% Select the intersection of the subjects

if(M == 1)
    subjects = S{1};
else
    subjects = intersect(S{1},S{2});
end

end