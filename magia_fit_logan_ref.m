function [DVR,intercept,X,Y,k] = magia_fit_logan_ref(tacs,ref_tac,frames,start_time,end_time,refk2)

if(end_time == 0)
    end_time = frames(end,2);
end

nFrames = size(frames,1);
if(size(tacs,1) ~= nFrames && size(tacs,2) == nFrames)
    tacs = tacs';
end
nTACs = size(tacs,2);
t = mean(frames,2);

%integrate ref tac
auc_input = cumtrapz(t,ref_tac);

% integrate output
auc_pet = cumtrapz(t,tacs);

Y = auc_pet ./ tacs;
X = (repmat(auc_input,[1 nTACs])./tacs) + (repmat(ref_tac,[1 nTACs])./tacs)/refk2;

DVR = nan([1 nTACs]);
intercept = nan([1 nTACs]);
k = frames(:,1) >= start_time & frames(:,2) <= end_time;
if(sum(k) >= 2)
    for i = 1:nTACs
        A = [X(:,i) ones(nFrames,1)];
        x = A(k,:)\Y(k,i);
        DVR(i)  = x(1);
        intercept(i) = x(2);
    end
end

end