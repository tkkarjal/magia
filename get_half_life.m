function half_life = get_half_life(tracer)

idx1 = regexp(tracer,'[');
idx2 = regexp(tracer,']');
isotope = tracer((idx1+1):(idx2-1));

switch isotope
    case '11c'
        half_life = 20.4;
    case '18f'
        half_life = 109.9;
end

end