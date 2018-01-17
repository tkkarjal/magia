function isotope = aivo_get_isotope_from_tracer(tracer)

idx = regexp(tracer,'[[]]');
isotope = tracer(idx(1)+1:idx(2)-1);

end