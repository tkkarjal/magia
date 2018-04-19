function furs = magia_calculate_fur(input,tacs,frames,start_time,end_time,ic)
% Calculates FUR

% Select the frames between start_time and end_time
if(end_time == 0)
    end_time = frames(end);
end
k = frames(:,1) >= start_time & frames(:,2) <= end_time;

if(any(k))
    frames = frames(k,:);
    tacs = tacs(:,k);
else
    error('Could not calculate ROI FURs because there are no frames between start_time and end_time.');
end

% Calculate FUR integral
I = calculate_fur_integral(input,frames);
if(ic)
    tmid = 0.5*(frames(1)+frames(end));
    cp = spline(input(:,1),input(:,2),tmid);
    furs = (mean(tacs,2)-ic*cp)./I;
else
    furs = mean(tacs,2)./I;
end

if(max(furs)>10)
    furs = furs*0.001;
elseif(max(furs)<1e-3)
    furs = furs*1000;
end

end