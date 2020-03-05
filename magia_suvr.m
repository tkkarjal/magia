function suvr = magia_suvr(input,tacs,frames,start_time,end_time)

num_frames = size(frames,1);
if(num_frames > 1)
    if(end_time == 0)
        end_time = frames(end);
    end
    k = frames(:,1) >= start_time & frames(:,2) <= end_time;
    if(any(k))
        frames = frames(k,:);
        frame_durs = frames(:,2) - frames(:,1);
        input = input(k);
        tacs = tacs(:,k);
        ref_auc = sum(frame_durs.*input);
        roi_aucs = sum(repmat(frame_durs',[size(tacs,1) 1]).*tacs,2);
        suvr = roi_aucs./ref_auc;
    else
        error('Could not calculate SUVR because there are no data points between the specified start and end times.');
    end
else
    suvr = tacs./input;
end
    
end
