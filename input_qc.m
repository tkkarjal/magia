function input_qc(subject,input,frames)

dose = aivo_get_info(subject,'dose');
if(dose > 2.1)
    weight = aivo_get_info(subject,'weight');
    if(weight > 0)
        if(max(input) > 1000)
            input = input*0.001;
        end
        c = dose/weight;
        input = input/c;
        
        t = mean(frames,2);
        tracer = aivo_get_info(subject,'tracer');
        if(iscell(tracer))
            tracer = tracer{1};
        end
        try
            fig = calculate_input_boundaries(tracer);
            title('Reference tissue input inspection');
            hold on; plot(t,input,'k','LineWidth',2);
            xlim([0 t(end)]);
            add_to_qc_pic(subject,fig)
            close(fig);
        catch
            warning('Could not create input qc figure.');
        end
    end
end

end