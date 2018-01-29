function subjects = aivo_get_subjects(varargin)

% Finds subjects that match the specified criteria in the AIVO database.
% You can set multiple criteria simultaneously. If a criterium is related
% to a numeric variable, you can specify lower and upper bounds for the
% variable.
%
% Format:
%      age/dose/height/weight = '~0' or '20' or {20,30}
%      study_date = '~0' or 'YYYY-MM-DD' or {'YYYY-MM-DD','YYYY-MM-DD'}
%      injection_time = '~0' or 'hh:mm:ss' or {'hh:mm:ss','hh:mm:ss'}
%
% The function returns a list of ac-numbers/study codes.
%
%
% Examples:
%
% A) Find all [18f]fdg subjects
%      subjects = aivo_get_subjects('tracer','[18f]fdg');
%
% B) Find all subjects that have not been scanned with [18f]fdg
%      subjects = aivo_get_subjects('tracer','~[18f]fdg');
%
% C) Find all female subjects that have been scanned with [18f]fdg
%      subjects = aivo_get_subjects('gender','f','tracer','[18f]fdg');
%
% E) Find all female subjects between ages 20 and 30
%      subjects = aivo_get_subjects('gender','f','age',{20,30});
%
% G) Find all subjects between study dates YYYY-MM-DD and YYYY-MM-DD
%      subjects = aivo_get_subjects('study_dates',{'YYYY-MM-DD','YYYY-MM-DD'};
%
% H) Find all [11c]carfentanil subjects with MRI
%      subjects = aivo_get_subjects('tracer','[11c]carfentanil','mri','~0');
%
% I) Find all freesurfed subjects 
%      subjects = aivo_get_subjects('freesurfed',1);
%

conn = aivo_connect();

if((~mod(nargin,2)))
    
    select_statement = 'SELECT pet.image_id FROM "megabase"."aivo".pet ';
    where_statement = 'WHERE ';
    l=0;
    for i=1:nargin/2
        field = varargin{i+l};
        value = varargin{i+l+1};
        l=l+1;
        if(ismember(field,{'age','dose','study_date','injection_time','height','weight'})) %value
            if(ischar(value)) %only one value
                if(ismember('~',value))  %exclude spesific value
                    where_statement = [where_statement,' NOT ','pet.',lower(field),' = ',char(39),value(2:length(value)),char(39)];
                else
                    where_statement = [where_statement,'pet.',lower(field),' = ',char(39),value,char(39)];
                end
            else
                lb = value{1}; % lower bound
                ub = value{2}; % upper bound
                if(or(strcmp(field,'study_date'),strcmp(field,'injection_time')))
                    value = [char(39),num2str(lb),char(39),' AND ',char(39),num2str(ub),char(39)];
                else
                    value = [num2str(lb),' AND ',num2str(ub)];
                end
                where_statement = [where_statement,'pet.',lower(field),' BETWEEN ',value];
            end
            if(i~=nargin/2)
                where_statement = [where_statement,' AND '];
            end
        end
        if(ismember(field,{'gender','study_code','tracer','frames','scanner','mri','project','description','group_name','patient_id','source','type','ac' 'githash'})) %char
            if(ismember('~',value)) %user excludes spesified values
                where_statement = [where_statement,' NOT ','pet.',lower(field),'=',char(39),value(2:length(value)),char(39)];
                if(i~=nargin/2)
                    where_statement = [where_statement,' AND '];
                end
            else
                where_statement = [where_statement,'pet.',lower(field),'=',char(39),value,char(39)];
                if(i~=nargin/2)
                    where_statement = [where_statement,' AND '];
                end
            end
        end
        if(ismember(field,{'validated','analyzed','found','freesurfed','rc','dc','plasma' 'dynamic'})) %integer or char
            if(ismember('~',value)) %user excludes spesified values, value is char
                where_statement = [where_statement,' NOT ','pet.',lower(field),'=',char(39),value(2:length(value)),char(39)];
                if(i~=nargin/2)
                    where_statement = [where_statement,' AND '];
                end
            else
                if(isnumeric(value)) % value may be char or numeric
                    value = num2str(value);
                end
                where_statement = [where_statement,'pet.',lower(field),'=',char(39),value,char(39)];
                if(i~=nargin/2)
                    where_statement = [where_statement,' AND '];
                end
            end
        end 
    end
    if(nargin==0)
        q = select_statement;
    else
        q = [select_statement,where_statement,'ORDER BY image_id ASC;'];
    end
    curs = exec(conn,q);
    curs = fetch(curs);
    close(curs);
    if(strcmp(curs.Data{1},'No Data'))
        subjects = [];
    else
        subjects = curs.Data;
    end
else
    error('You entered an odd number of input arguments. The input arguments must be given in pairs (criterium, value).');

end

close(conn);

end
