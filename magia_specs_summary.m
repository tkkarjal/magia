function [T_study, T_magia] = magia_specs_summary(subjects,model,norm_method)


archive_dir = getenv('MAGIA_ARCHIVE');
specs_files = strcat(archive_dir,'/',subjects,'/',model,'_',norm_method,'/specs_',subjects,'.txt');
n = length(subjects);

%% Read the specs

specs = cell(n,1);
for i = 1:n
    specs{i} = magia_read_specs(specs_files{i});
end

%% Get study labels

for i = 1:n
    study_specs = specs{i}.study;
    cur_fields = fieldnames(study_specs)';
    if(i == 1)
        study_labels = cur_fields;
    else
        study_labels = union(study_labels,cur_fields);
    end
end
m = length(study_labels);

%% Read study specs into a table

T_study = cell(n,m);

for i = 1:n
    study_specs = specs{i}.study;
    for j = 1:m
        lab = study_labels{j};
        if(isfield(study_specs,lab))
            T_study{i,j} = study_specs.(lab);
        end
    end
end

T_study = cell2table(T_study);
T_study.Properties.VariableNames = study_labels;
T_study.Properties.RowNames = subjects;

%% Get magia labels

for i = 1:n
    magia_specs = specs{i}.magia;
    cur_fields = fieldnames(magia_specs)';
    if(i == 1)
        magia_labels = cur_fields;
    else
        magia_labels = union(magia_labels,cur_fields);
    end
end
m = length(magia_labels);

%% Read magia specs into a table

T_magia = cell(n,m);

for i = 1:n
    magia_specs = specs{i}.magia;
    for j = 1:m
        lab = magia_labels{j};
        if(isfield(magia_specs,lab))
            T_magia{i,j} = magia_specs.(lab);
        end
    end
end

T_magia = cell2table(T_magia);
T_magia.Properties.VariableNames = magia_labels;
T_magia.Properties.RowNames = subjects;

end
