function coreg_qc(subject,pet_image,mr_image)
% Visualizes orthogonal slices of PET and MR images. The MRI is shown as a
% red overlay on top of the PET image. The visualization is saved to the
% subject's qc file.

% Define values related to positioning of the slices
d = 0.05;
w = 0.8/3;
h = 0.8;
y = 0.1;

N = 4; % number of slices

% Define the slices (in millimiters) that are shown
xx = [-15 -5 5 15];
yy = [-20 0 10 40];
zz = [-20 0 20 40];

ff = figure('Position',[10 10 900 1200],'Visible','Off');

for i = 1:N
    
    fig = spm_figure('Create','Graphics','','off');
    fig.Position = [796 25 1200 400];
    
    clear global st
    
    k = spm_orthviews('image',pet_image);
    spm_orthviews('AddColouredImage',k,mr_image,[1 0 0]);
    spm_orthviews('Xhairs','off')
    spm_orthviews('reposition',[xx(i) yy(i) zz(i)]);
    spm_orthviews('redraw');
    
    ax = fig.Children;
    
    ax(1).Position(1) = d;
    ax(2).Position(1) = 2*d+w;
    ax(3).Position(1) = 3*d+2*w;
    
    ax(1).Position(2) = y;
    ax(2).Position(2) = y;
    ax(3).Position(2) = y;
    
    ax(1).Position(3) = w;
    ax(2).Position(3) = w;
    ax(3).Position(3) = w;
    
    ax(1).Position(4) = h;
    ax(2).Position(4) = h;
    ax(3).Position(4) = h;
    
    figstruct = getframe(fig);
    close(fig);
    X = figstruct.cdata;
    
    subplot(N,1,i); imshow(X);
    
end

add_to_qc_pic(subject,ff)
close(ff);

end