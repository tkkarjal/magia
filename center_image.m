function W = center_image(filename)

if(~ischar(filename))
    error('The input argument filename has to be a string.');
end

V = spm_vol(filename);
N = length(V);
if(N==1)
    W = cg_set_com_mod(filename);
elseif(N>1)
    % Create sum image
    [p,n,e] = fileparts(filename);
    sum_filename = fullfile(p,[n '_tempsum' e]);
    img = spm_read_vols(V);
    sum_img = sum(img,4);
    V0 = V(1);
    V0.fname = sum_filename;
    spm_write_vol(V0,sum_img);
    
    % Estimate orientation matrix using the sum image
    W = cg_set_com_mod(sum_filename);
    delete(sum_filename);
    
    % Use the orientation matrix for all the individual images
    images = cellstr(spm_select('ExtFPList',p,[n e]));
    for i = 1:N
        spm_get_space(images{i},W);
    end
    %spm_reorient(images,W);
else
    error('Could not center %s. There is possibly something wrong with the file.\n',filename);
end

end