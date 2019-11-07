function found = aivo_check_found(image_id,varargin)

if(nargin == 1)
    table_name = 'study';
else
    table_name = varargin{1};
end

if(ischar(image_id))
    image_id = {image_id};
end

available_tables = {'study' 'magia' 'patient' 'lab' 'project' 'inventory' 'mri'};

if(~ismember(table_name,available_tables))
    error('Unrecognized table name: %s',table_name);
end

q = sprintf('SELECT %s.image_id FROM "megabase"."aivo2".%s ',table_name,table_name);

conn = aivo_connect();
curs = exec(conn,q);
curs = fetch(curs);
close(curs);
close(conn);

table_image_ids = curs.Data;

found = ismember(image_id,table_image_ids);

end