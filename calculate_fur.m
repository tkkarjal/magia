function furs = calculate_fur(input,tacs,frames)

I = calculate_fur_integral(input,frames);
furs = tacs./I;
if(max(furs)>10)
    furs = furs*0.001;
end

end