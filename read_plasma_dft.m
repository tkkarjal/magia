function plasmadata = read_plasma_dft(filename)

fid = fopen(filename);

res = cell(200,1);
o = 0;
l = fgetl(fid);
while(isempty(find(regexp(l,'Time'),1)))
    l = fgetl(fid);
end
l = fgetl(fid);
while(l~=-1)
    if(isempty(find(regexp(l,'#'),1)))
        l = strtrim(l);
        k = '';
        for j = 1:length(l)
            c = l(j);
            if(~isempty(regexp(c,'\d','once')) || strcmp(c,'.') || strcmp(c,'e') || strcmp(c,'+') || strcmp(c,'-'))
                % numeric
                k =  [k c];
                if(j==length(l))
                    o = o + 1;
                    res{o} = k;
                end
            else
                % not numeric
                if(~isempty(k))
                    o = o + 1;
                    res{o} = k;
                    k = '';
                end
            end
        end
    end
    l = fgetl(fid);
end

fclose(fid);

res(cellfun(@isempty,res)) = [];

plasmadata = zeros(size(res,1)/2,2);
plasmadata(:,1) = str2double(res(1:2:end));
plasmadata(:,2) = str2double(res(2:2:end));

end