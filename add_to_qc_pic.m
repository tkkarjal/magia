function add_to_qc_pic(subject,figure)
% Adds the Matlab figure to the subject's QC file.

data_path = getenv('DATA_DIR');
qc_pic_fname = sprintf('%s/%s/qc_%s.ps',data_path,subject,subject);
if(~exist(qc_pic_fname,'file'))
    print('-painters','-bestfit','-r150','-noui',figure,'-dpsc',qc_pic_fname);
else
    print('-painters','-bestfit','-r150','-noui',figure,'-dpsc','-append',qc_pic_fname);
end
    
end