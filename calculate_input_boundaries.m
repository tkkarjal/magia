function fig = calculate_input_boundaries(tracer)

archive_dir = getenv('MAGIA_ARCHIVE');
subjects = aivo_get_subjects('tracer',tracer,'analyzed',1,'mri','~0','dose',{100 1000},'weight',{40 200});
N = length(subjects);

inputs = cell(N,1);
frames = cell(N,1);
tmax = 0;

doses = aivo_get_info(subjects,'dose');
weights = aivo_get_info(subjects,'weight');

for i = 1:N
    sub = subjects{i};
    dose = doses(i);
    weight = weights(i);
    c = dose/weight;
    tac_fname = sprintf('%s/%s/results/tacs/tacs.mat',archive_dir,sub);
    if(exist(tac_fname,'file'))
        I = load(tac_fname);
        h = I.input;
        if(max(h)>1000)
            h = 0.001*h;
        end
        inputs{i} = h/c;
        frames{i} = I.frames;
        if(max(mean(I.frames,2)) > tmax)
            tmax = max(mean(I.frames,2));
        end
    end
end

idx = cellfun(@isempty,inputs);
inputs(idx) = [];
frames(idx) = [];

N = N - sum(idx);

tt = 0:0.5:tmax;

inter_inputs = nan(N,length(tt));

for i = 1:N
    y = inputs{i};
    t = mean(frames{i},2);
    idx = tt >= t(1) & tt <= t(end);
    ttt = tt(idx);
    inter_inputs(i,idx) = pchip(t,y,ttt);
end

inter_inputs(:,1) = 0;

S = sum(~isnan(inter_inputs),1);

proper_idx = S >= 15;

inter_inputs = inter_inputs(:,proper_idx);
tt = tt(proper_idx);

median_input = median(inter_inputs,1,'omitnan');

lb_p = 10:5:45;
ub_p = 55:5:90;

fig = figure('Visible','Off');

plot(tt,median_input,'b','LineWidth',2); hold on;
for i = 1:length(lb_p)
    lb = prctile(inter_inputs,lb_p(i),1);
    ub = prctile(inter_inputs,ub_p(i),1);
    y = [lb;ub];
    plotshaded(tt,y,'b')
    title(sprintf('Canonical reference tissue input for %s',tracer));
    ylabel('SUV'); xlabel('Time (min)');
end

box off; xlim([0 tt(end)]);

end
