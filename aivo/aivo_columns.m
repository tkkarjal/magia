function column_names = aivo_columns(conn, table_name)

if(strcmp(table_name, 'materia'))
    query = 'SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod), a.attnotnull FROM pg_attribute a JOIN pg_class t on a.attrelid = t.oid JOIN pg_namespace s on t.relnamespace = s.oid WHERE a.attnum > 0 AND NOT a.attisdropped AND t.relname = ''materia'' AND s.nspname = ''aivo2'' ORDER BY a.attnum;';
else
    query = sprintf('SELECT * FROM information_schema.columns WHERE table_schema = ''aivo2'' AND table_name = ''%s''', table_name);
end

data = fetch(conn, query);

if(isempty(data))
    error('Could not find a table named ''%s'' from the schema ''aivo2''.', table_name);
end

if(strcmp(table_name, 'materia'))
    column_names = data.attname';
else
    column_names = data.column_name';
end

end