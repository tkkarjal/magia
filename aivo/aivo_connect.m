function conn = aivo_connect()

conn = check_megabase_conn();
if(isempty(conn))
    conn = database('megabase', 'malmsteen', ' ', 'Vendor', 'POSTGRESQL', 'Server', 'localhost', 'PortNumber', 5432);
end

end