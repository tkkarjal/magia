function max_num_of_consecutive_values = magia_max_consecutive_values(v,n)

    f = find([true,diff(v)~=0,true]);
    y = zeros(1,n);
    y(f(1:end-1)) = diff(f);
    max_num_of_consecutive_values = max(cumsum(y(1:n))-(1:n) + 1);
    
end

