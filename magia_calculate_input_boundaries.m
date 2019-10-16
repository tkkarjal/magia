function fig = magia_calculate_input_boundaries(tracer,input_type)

archive_dir = getenv('MAGIA_ARCHIVE');

if(plasma)
    subjects = aivo_get_subjects('tracer',tracer,'analyzed',1,'plasma',1,'dose',{100 1000},'weight',{40 200});
else
    subjects = aivo_get_subjects('tracer',tracer,'analyzed',1,'mri','~0','dose',{100 1000},'weight',{40 200});
end
N = length(subjects);

inputs = cell(N,1);
times = cell(N,1);
tmax = 0;

doses = aivo_get_info(subjects,'dose');
weights = aivo_get_info(subjects,'weight');

for i = 1:N
    sub = subjects{i};
    dose = doses(i);
    weight = weights(i);
    c = dose/weight;
    if(plasma)
        input = read_plasma(sub);
        t = input(:,1);
        input = input(:,2);
    else
        tac_fname = sprintf('%s/%s/results/tacs/tacs.mat',archive_dir,sub);
        I = load(tac_fname);
        input = I.input;
        t = mean(I.frames,2);
    end
    if(max(input)>1000)
        input = 0.001*input;
    end
    inputs{i} = input/c;
    times{i} = t;
    if(max(t) > tmax)
        tmax = max(t);
    end
end

idx = cellfun(@isempty,inputs);
inputs(idx) = [];
times(idx) = [];

N = N - sum(idx);

tt = 0:0.1:tmax;

inter_inputs = nan(N,length(tt));

for i = 1:N
    y = inputs{i};
    t = mean(times{i},2);
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

plot(tt,median_input,'b--','LineWidth',1.5); hold on;
for i = 1:length(lb_p)
    lb = prctile(inter_inputs,lb_p(i),1);
    ub = prctile(inter_inputs,ub_p(i),1);
    y = [lb;ub];
    plotshaded(tt,y,'b')
end
ylabel('SUV'); xlabel('Time (min)');
if(plasma)
    title(sprintf('Canonical plasma input curve for %s',tracer));
else
    title(sprintf('Canonical reference tissue input for %s',tracer));
end
box off; xlim([0 tt(end)]);

end
