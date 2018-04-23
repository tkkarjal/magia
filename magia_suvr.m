function suvr = magia_suvr(input,tacs,frames,start_time,end_time)

num_frames = size(frames,1);
if(num_frames > 1)
    k = frames(:,1) >= start_time & frames(:,2) <= end_time;
    if(any(k))
        frames = frames(k,:);
        input = input(k);
        tacs = tacs(:,k);
        t = mean(frames,2);
        ref_auc = trapz(t,input);
        roi_aucs = trapz(t,tacs')';
        suvr = roi_aucs./ref_auc;
    else
        error('Could not calculate SUVR because there are no data points between the specified start and end times.');
    end
else
    suvr = tacs./input;
end
    
end