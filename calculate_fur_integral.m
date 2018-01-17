function fur_integral = calculate_fur_integral(input,frames)

t = input(:,1);
dt = min(t(2:end,1) - t(1:end-1,1));
tt = t(1):dt:t(end);
a = input(:,2);
a = spline(t,a,tt);
de = frames(1) + (frames(2)-frames(1))/2;
idx = find(tt>de,1,'first');
fur_integral = trapz(tt(1:idx),a(1:idx));

end