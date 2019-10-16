function bad_frames = magia_identify_bad_frames(filename)

[~,n] = fileparts(filename);

fprintf('Identifying bad frames for %s...',n);

V = spm_vol(filename);
img = spm_read_vols(V);
nx = size(img,1);
ny = size(img,2);
N = size(img,4);

bad_frames = false(N,1);

for i = 1:N
    mean_axial_slice = mean(img(:,:,:,i),3);
    xmean = mean(mean_axial_slice,2)';
    ymean = mean(mean_axial_slice,1);
    
%     figure(1); clf; imagesc(mean_axial_slice);
%     figure(2); clf; subplot(2,1,1); bar(xmean); subplot(2,1,2); bar(ymean);
    
    xpos = xmean > 0;
    ypos = ymean > 0;
    
    max_consecutive_pos_x = magia_max_consecutive_values(xpos,nx);
    max_consecutive_pos_y = magia_max_consecutive_values(ypos,ny);
    
    prop_pos_x = max_consecutive_pos_x/nx;
    prop_pos_y = max_consecutive_pos_y/ny;
    
    if(prop_pos_x < 0.4 || prop_pos_y < 0.5)
        bad_frames(i) = true;
    end

end

fprintf(' Done.\n');
if(~any(bad_frames))
    fprintf('No bad frames detected for %s.\n',n);
else
    frame_idx = find(bad_frames);
    M = length(frame_idx);
    msg = sprintf('The following frames were identified as bad for %s:',n);
    for i = 1:M
        msg = sprintf('%s %.0f',msg,frame_idx(i));
    end
    fprintf('%s\n',msg);
end

end