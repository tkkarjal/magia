function updated_val = aivo_import_check(val,column,row)

switch column
    case 'patient_id'
        d = str2double(val(1:2));
        mo = str2double(val(3:4));
        if(d <= 0 || d > 31 || mo <= 0 || mo > 12 || length(val) ~= 11)
            error('Invalid patient_id on row %.0f',row);
        else
            updated_val = val;
        end
    case 'ac_number'
        if(length(val) ~= 7)
            error('Invalid ac_number on row %.0f. The AC number is supposed to have 7 characters.',row);
        else
            updated_val = lower(val);
        end
    case 'study_date'
        try
            val = char(datetime(val,'format','yyyy-MM-dd'));
            h = strsplit(val,'-');
            y = str2double(h{1});
            mo = str2double(h{2});
            d = str2double(h{3});
            if(y < 1989 || d > 31 || mo <= 0 || mo > 12)
                error('Invalid study_date on row %.0f',row);
            else
                updated_val = lower(val);
            end
        catch
            
            
        end
    case 'tracer'
        if(~strcmp(val(1),'['))
            error('Invalid tracer name on row %.0f. Please use the following notation: [18f]fdg',row);
        else
            updated_val = lower(val);
        end
    case 'mri_code'
        if(length(val) ~= 7)
            error('Invalid mri_code on row %.0f. The AC number is supposed to have 7 characters.',row);
        else
            updated_val = lower(val);
        end
    case 'injection_time'
        idx = regexp(val,' ');
        val(idx) = [];
        updated_val = val;
    case 'group_name'
        idx = regexp(val,' ');
        val(idx) = '_';
        updated_val = lower(val);
    case {'project' 'description' 'scanner'}
        idx = regexp(val,' ');
        val(idx) = '-';
        updated_val = lower(val);
    otherwise
        updated_val = val;

end
