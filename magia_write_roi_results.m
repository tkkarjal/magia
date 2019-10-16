function magia_write_roi_results(T,results_dir)

f = sprintf('%s/roi_results.mat',results_dir);
save(f,'T');
f = sprintf('%s/roi_results.csv',results_dir);
writetable(T,f,'WriteRowNames',1);

end