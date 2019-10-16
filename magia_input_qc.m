function magia_input_qc(subject,input,study_specs)

if(isnan(study_specs.dose) || study_specs.dose <= 0)
    fprintf('Could not create input QC figure because the dose has not been specified for %s.\n',subject);
    return;
end

if(isnan(study_specs.weight) || study_specs.weight <= 0)
    fprintf('Could not create input QC figure because the weight has not been specified for %s.\n',subject);
    return;
end

if(strcmp(study_specs.tracer,'unknown'))
    fprintf('Could not create input QC figure for %s because the tracer has not been specified.\n',subject);
    return;
end

switch study_specs.input_type
    case {'plasma','blood'}
        t = input(:,1);
        input = input(:,2);
        p = 1;
    case {'ref' 'sca_ref'}
        t = mean(study_specs.frames,2);
        p = 0;
end

% Convert to kBq
if(max(input) > 1000)
    input = input*0.001;
end

% Convert to SUV
c = study_specs.dose/study_specs.weight;
suv_input = input/c;

try
    fig = magia_calculate_input_boundaries(study_specs.tracer,p);
    title('Input function inspection');
    hold on; plot(t,suv_input,'k','LineWidth',1.5);
    xlim([0 t(end)]);
    add_to_qc_pic(subject,fig)
    close(fig);
catch
    warning('Could not create input qc figure.');
end

end