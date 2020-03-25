function input = magia_read_input(filename)

if(isempty(filename))
    error('Could not read input data.');
end
if(iscell(filename))
    filename = filename{1};
end
if(~exist(filename,'file'))
    error('%s: Could not read file %s because it does not exist.',subject,filename);
end

[~,~,ext] = fileparts(filename);
if(strcmpi(ext,'dft'))
    input = read_input_dft(filename);
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
    
    % Parse the input data
    i = 0;
    while(l~=-1)
        if(ischar(l))
            i = i + 1;
            h = strsplit(l,' ');
            if(length(h)==1)
                h = strsplit(l,'	');
            end
            h(cellfun(@isempty,h)) = [];
            input(i,1) = str2double(h{1}); % time
            input(i,2) = str2double(h{2}); % radioactivity
        end
        l = fgetl(fid);
    end
    fclose(fid);
end

% Remove measurements before time zero
k = input(:,1) >= 0;
input = input(k,:);

k = ~isnan(input(:,2));
input = input(k,:);

maxT = max(input(:,1));
if(maxT > 300)
    input(:,1) = input(:,1)/60;
end

if(input(1,1)>0)
    input = [0 0;input];
end

zero_time_idx = input(:,1) == 0;
if(sum(zero_time_idx)>1)
    last_zero_time_idx = find(zero_time_idx,1,'last');
    input = input(last_zero_time_idx:end,:);
end

% Throw an error if there are duplicate time points
T = tabulate(input(:,1));
if(any(T(:,2) > 1))
    error('Found duplicate time-points from the input file %s',filename);
end

end