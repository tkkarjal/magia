function parametric_image_qc(subject,model)

data_path = getenv('DATA_DIR');
d = sprintf('%s/%s/results',data_path,subject);
switch model
    case 'srtm'
        f = sprintf('%s/swrpet_%s_bfsrtm_BP.nii',d,subject);
        msg = sprintf('BPnd QC: %s',subject);
    otherwise
        f = '';
end

if(~isempty(f))
    V = spm_vol(f);
    img = spm_read_vols(V);
    
    voxel_sizes = sqrt(sum((V.mat(1:3,1:3)).^2,1));
    
    dx = floor(8/voxel_sizes(1)); % 8 mm
    dy = floor(8/voxel_sizes(2)); % 8 mm
    dz = floor(10/voxel_sizes(3)); % 10 mm
    
    mx = floor(median(1:size(img,1)));
    my = floor(median(1:size(img,2)));
    mz = floor(median(1:size(img,3)));
    
    M = 3;
    x_grid = mx-M*dx:dx:mx+M*dx;
    y_grid = my-M*dy:dy:my+M*dy;
    z_grid = mz-M*dz:dz:mz+M*dz;
    
    N = length(x_grid);
    
    fig = figure('Position',[734 4 1126 1322],'Visible','Off'); hold on;
    
    for i = 1:N
        x_slice = squeeze(img(x_grid(i),:,:))';
        y_slice = squeeze(img(:,y_grid(i),:))';
        z_slice = squeeze(img(:,:,z_grid(i)))';
        
        subplot(N,3,3*i-2);
        imagesc(x_slice);
        set(gca,'YDir','normal')
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        
        if(i==1)
            title(msg);
        end
        
        subplot(N,3,3*i-1);
        imagesc(y_slice);
        set(gca,'YDir','normal')
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        
        subplot(N,3,3*i);
        imagesc(z_slice);
        set(gca,'YDir','normal')
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        
    end
    
    colormap hot
    
    add_to_qc_pic(subject,fig)
    close(fig);
    
end

end