function T = roi_fitting(tacs,input,frames,modeling_options,roi_info,varargin)

% N ROIs
% M frames
% tacs = N x M matrix

model = lower(modeling_options.model);

% Make sure input is not one of the tacs
if(min(size(input))==1)
    I = repmat(input',[size(tacs,1) 1]);
    idx = sum(I-tacs~=0,2) > 0;
    tacs = tacs(idx,:);
    roi_info.labels = roi_info.labels(idx);
end

N = size(tacs,1);

switch model
    case 'srtm'
        X = zeros(N,3);
        n_iterations = 50;
        lb = modeling_options.lb;
        ub = modeling_options.ub;
        for i = 1:N
            fprintf('SRTM: Fitting ROI %.0f/%.0f...\n',i,N); 
            [~,X(i,:)] = fit_srtm(tacs(i,:),input,frames,lb,ub,n_iterations);
        end
        T = array2table(X,'VariableNames',{'R1','k2','BPnd'},'RowNames',roi_info.labels);
    case 'patlak'
        X = zeros(N,2);
        startTime = modeling_options.start_time;
        cutFrame = modeling_options.end_frame;
        if(cutFrame==0)
            cutFrame = size(frames,1);
        end
        for i = 1:N
            fprintf('Patlak: Fitting ROI %.0f/%.0f...\n',i,N);
            [X(i,1),X(i,2)] = metpet_fit_patlak(input,tacs(i,:),frames,startTime,cutFrame);
        end
        T = array2table(X,'VariableNames',{'Ki','V0'},'RowNames',roi_info.labels);
    case 'patlak_ref'
        X = zeros(N,2);
        startTime = modeling_options.start_time;
        cutTime = modeling_options.cut_time;
        if(~cutTime)
            cutTime = frames(end,2);
        end
        for i = 1:N
            fprintf('Patlak_ref: Fitting ROI %.0f/%.0f...\n',i,N);
            [X(i,1),X(i,2)] = magia_fit_patlak_ref(input,tacs(i,:),frames,startTime,cutTime);
        end
        T = array2table(X,'VariableNames',{'Ki','V0'},'RowNames',roi_info.labels);
    case 'fur'
        X = calculate_fur(input,tacs,frames);
        T = array2table(X,'VariableNames',{'FUR'},'RowNames',roi_info.labels);
    case 'suvr_dyn'
        startTime = modeling_options.start_time;
        endTime = modeling_options.end_time;
        X = magia_suvr_dyn(input,tacs,frames,startTime,endTime);
        T = array2table(X,'VariableNames',{'SUVR'},'RowNames',roi_info.labels);
    case 'static_ratio'
        X = calculate_static_ratio(input,tacs);
        T = array2table(X,'VariableNames',{'SUVR'},'RowNames',roi_info.labels);
    case '2tcm'
        X = zeros(N,6);
        %lb = modeling_options.lb;
        %ub = modeling_options.ub;
        for i = 1:N
            fprintf('Two-tissue compartmental model: Fitting ROI %.0f/%.0f...\n',i,N);
            [~,x_optim,~,vt] = magia_fit_2tcm_iterative(roi_tac,t_plasma,ca,cb,frames);
            % HUOM PITÄÄ MUOKATA MAGIAA SITEN ETTÄ CB VOI TULLA MUKAAN
            X(i,1:5) = x_optim;
            X(i,6) = vt;
        end
        T = array2table(X,'VariableNames',{'K1','K1/k2','k3','k3/k4','vb','vt'},'RowNames',roi_info.labels);
    otherwise
        error('ROI fitting has not been implemented for %s.',model);
end

if(nargin==6)
    results_dir = varargin{1};
    f = sprintf('%s/roi_results.mat',results_dir);
    save(f,'T');
    f = sprintf('%s/roi_results.csv',results_dir);
    writetable(T,f,'WriteRowNames',1);
end

end