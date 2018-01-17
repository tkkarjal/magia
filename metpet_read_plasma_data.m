function plasmadata = metpet_read_plasma_data(filename)

[~,~,ext] = fileparts(filename);
if(strcmpi(ext,'dft'))
    plasmadata = read_plasma_dft(filename);
else
    
    fid = fopen(filename,'r');
    
    % Get rid of comments (#) in the beginning
    l = fgetl(fid);
    while(strcmp(l(1),'#'))
        l = fgetl(fid);
        if(isempty(l))
            l = fgetl(fid);
            break;
        end
    end
    
    % Parse the plasma data
    i = 0;
    while(l~=-1)
        if(ischar(l))
            i = i + 1;
            h = strsplit(l,' ');
            if(length(h)==1)
                h = strsplit(l,'	');
            end
            h(cellfun(@isempty,h)) = [];
            plasmadata(i,1) = str2double(h{1}); % time
            plasmadata(i,2) = str2double(h{2}); % plasma radioactivity
        end
        l = fgetl(fid);
    end
    
    fclose(fid);
    
end

% Remove measurements before time zero
k = plasmadata(:,1)>=0;
plasmadata = plasmadata(k,:);

k = ~isnan(plasmadata(:,2));
plasmadata = plasmadata(k,:);

maxT = max(plasmadata(:,1));
if(maxT > 300)
    plasmadata(:,1) = plasmadata(:,1)/60;
end

% neg_idx = plasmadata(:,2) < 0;
% plasmadata(neg_idx,2) = 0;

if(plasmadata(1,1)>0)
    plasmadata = [0 0;plasmadata];
end

end