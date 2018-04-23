function suvr = magia_suvr_dyn(input,tacs,frames,start_time,end_time)

idx = start_time <= frames(:,1) & end_time >= frames(:,2);
if(any(idx))
    t = mean(frames,2);
    t = t(idx);
    input = input(idx);
    tacs = tacs(:,idx);
    
    ref_auc = trapz(t,input);
    roi_aucs = trapz(t,tacs')';
    
    suvr = roi_aucs./ref_auc;
else
    error('Could not calculate SUVR because there are no data points between the specified start and end times.');
end

end