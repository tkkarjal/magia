function suvr = magia_suvr_dyn(input,tacs,frames,startTime,endTime)

t = mean(frames,2);
N = size(tacs,1);

idx = startTime >= frames(:,1) & endTime <= frames(:,2);

ref_auc = trapz(t(idx),input(idx));
roi_aucs = zeros(N,1);

for i = 1:N
    roi_aucs(i) = trapz(t(idx),tacs(i,idx));
end

suvr = roi_aucs./ref_auc;

end