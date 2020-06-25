function specs = magia_match_input_to_model(specs)
% Matches the selected model with the appropriate input type.
%
% If there is a mismatch between the specified model and the input type,
% Magia assumes that the model has been correctly specified and changes the
% input type to match the model.
%
% Tomi Karjalainen, September 19th, 2019

switch specs.magia.model
    case {'logan_ref' 'patlak_ref' 'suvr' 'srtm'}
        % The input_type can be either 'ref' or 'sca_ref'
        % If the classfile has been specified, then it should be 'sca_ref',
        % otherwise 'ref'
        if(isfield(specs.magia,'classfile') && ~isempty(specs.magia.classfile))
            % classfile has been specified
            if(~strcmp(specs.magia.input_type,'sca_ref'))
                warning('''%s'' was entered as the input_type, even if it requires a ''sca_ref'' input when the ''classfile'' is specified in the specs. Changing the input type to ''sca_ref''.',specs.magia.input_type);
                specs.magia.input_type = 'sca_ref';
            end
        else
            % classfile has not been specified
            if(~strcmp(specs.magia.input_type,'ref'))
                warning('''%s'' was entered as the input_type, even if the model ''%s'' requires reference tissue input. Changing the input type to ''ref''.',specs.magia.input_type,specs.magia.model);
                specs.magia.input_type = 'ref';
            end
        end
    case {'patlak' 'fur' 'logan' 'ma1'}
        if(~strcmp(specs.magia.input_type,'plasma'))
            warning('''%s'' was entered as the input_type, even if the model ''%s'' requires plasma input. Changing the input type to ''plasma''.',specs.magia.input_type,specs.magia.model);
            specs.magia.input_type = 'plasma';
        end
    case 'two_tcm'
        if(~strcmp(specs.magia.input_type,'plasma&blood'))
            warning('''%s'' was entered as the input_type, even if the model ''%s'' requires plasma & blood inputs. Changing the input type to ''plasma&blood''.',specs.magia.input_type,specs.magia.model);
            specs.magia.input_type = 'plasma&blood';
        end
    case 'suv'
    
    otherwise
        error('Did not recognize the model %s.',specs.magia.model);
end

end
