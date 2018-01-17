function GM = fit_gaussian_mixture(x,k)

options = statset('MaxIter',10000);
N = 10;
M = cell(N,1);
BIC = zeros(N,1);
for i = 1:N
    M{i} = fitgmdist(x,k,'Options',options);
    BIC(i) = M{i}.BIC;
end

[~,min_idx] = min(BIC);

GM = M{min_idx};

end