function [y,x,e] = fit_srtm(roi_tac,ref_tac,times,lb,ub,n_iterations)

if(size(ref_tac,2)==1)
    ref_tac = ref_tac';
end
if(size(roi_tac,2)==1)
    roi_tac = roi_tac';
end

e = 1e10;
for i = 1:n_iterations
    x0 = metpet_random_init_srtm(lb,ub);
    [y_temp,x_temp,e_temp] = metpet_fit_srtm_iterative(roi_tac,ref_tac,times,x0,lb,ub);
    if(i==1 || e_temp<e)
        y = y_temp;
        x = x_temp;
        e = e_temp;
    end
end

end