function auc_ratios = calculate_auc_ratio(input,tacs,frames,startTime,endTime)

t = mean(frames,2);
N = size(tacs,1);

start_frame = find(startTime>=frames(:,1),1,'first');
end_frame = find(endTime<=frames(:,2),1,'last');

ref_auc = trapz(t(start_frame:end_frame),input(start_frame:end_frame));
roi_aucs = zeros(N,1);

for i = 1:N
    roi_aucs(i) = trapz(t(start_frame:end_frame),tacs(i,start_frame:end_frame));
end

auc_ratios = roi_aucs./ref_auc;

end