function magia_input_qc(subject,input,plasma)

dose = aivo_get_info(subject,'dose');
if(isnan(dose) || dose <= 0)
    fprintf('Could not create input QC figure because the dose has not been specified for %s.\n',subject);
    return;
end
weight = aivo_get_info(subject,'weight');
if(isnan(weight) || weight <= 0)
    fprintf('Could not create input QC figure because the weight has not been specified for %s.\n',subject);
    return;
end

tracer = aivo_get_info(subject,'tracer');
if(iscell(tracer))
    tracer = tracer{1};
end
if(strcmp(tracer,'unknown'))
    fprintf('Could not create input QC figure for %s because the tracer has not been specified.\n',subject);
    return;
end

if(plasma)
    t = input(:,1);
    input = input(:,2);
else
    fs = aivo_get_info(subject,'frames');
    if(iscell(fs))
        fs = fs{1};
    end
    frames = parse_frames_string(fs);
    t = mean(frames,2);
end

% Convert to kBq
if(max(input) > 1000)
    input = input*0.001;
end

% Convert to SUV
c = dose/weight;
suv_input = input/c;

try
    fig = magia_calculate_input_boundaries(tracer,plasma);
    title('Input function inspection');
    hold on; plot(t,suv_input,'k','LineWidth',1.5);
    xlim([0 t(end)]);
    add_to_qc_pic(subject,fig)
    close(fig);
catch
    warning('Could not create input qc figure.');
end

end