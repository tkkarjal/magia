function conn = check_megabase_conn()

S = evalin('base','whos');
N = length(S);

conn = '';

for i = 1:N
    varname = S(i).name;
    if(isopen(evalin('base',varname)))
        instance = evalin('base',sprintf('%s.Instance',varname));
        if(strcmp(instance,'megabase'))
            conn = evalin('base',varname);
            break;
        end
    end
end

end

function x = isopen(conn)

try
    x = ~conn.Constructor.isClosed;
catch
    x = 0;
end

end
