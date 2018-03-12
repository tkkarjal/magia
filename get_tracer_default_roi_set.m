function roi_info = get_tracer_default_roi_set(tracer)

switch lower(tracer)
    case {'[11c]carfentanil','[11c]pbr28'}
        roi_info.labels = {'amy' 'cau' 'dacc' 'hip' 'ins' 'nacc' 'ofc' 'pal' 'parhip' 'pcc' 'put' 'racc' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [1002 2002] % dacc
            [17 53] % hip
            [1035 2035] % ins
            [26 58] % nacc
            [1012 1014 2012 2014] % ofc
            [13 52] % pal
            [1016 2016] % parhip
            [1023 2023] % pcc
            [12 102 51 111] % put
            [1026 2026] % racc
            [9 10 48 49] % tha
            };
    case {'[11c]raclopride','[18f]cft','[18f]dopa'}
        roi_info.labels = {'amy' 'cau' 'hip' 'nacc' 'pal' 'parhip' 'put' 'tha'};
        roi_info.codes = {
        [18 54] % amy
        [11 50] % cau
        [17 53] % hip
        [26 58] % nacc
        [13 52] % pal
        [1016 2016] % parhip
        [12 102 51 111] % put
        [9 10 48 49] % tha
        };
    case '[11c]madam'
        roi_info.labels = {'amy' 'cau' 'dacc' 'hip' 'ins' 'medul' 'midbr' 'nacc' 'oc' 'ofc' 'pal' 'parhip' 'pcc' 'pons' 'put' 'racc' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [1002 2002] % dacc
            [17 53] % hip
            [1035 2035] % ins
            [175] % medul
            [173] % midbr
            [26 58] % nacc
            [1011 2011] % oc
            [1012 1014 2012 2014] % ofc
            [13 52] % pal
            [1016 2016] % parhip
            [1023 2023] % pcc
            [174] % pons
            [12 102 51 111] % put
            [1026 2026] % racc
            [9 10 48 49] % tha
            };
    case '[18f]fdg'
        roi_info.labels = {'amy' 'cau' 'dacc' 'hip' 'ins' 'nacc' 'ofc' 'parhip' 'pcc' 'pcun' 'put' 'racc' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [1002 2002] % dacc
            [1035 2035] % ins
            [17 53] % hip
            [26 58] % nacc
            [1012 1014 2012 2014] % ofc
            [1016 2016] % parhip
            [1023 2023] % pcc
            [1025 2025] % pcun
            [12 102 51 111] % put
            [1026 2026] % racc
            [9 10 48 49] % tha
            };
    case '[11c]pib'
        roi_info.labels = {'PIB1PFCALL' 'PARCALL' 'LTC' 'LOC' 'PREC' 'CGA' 'CGP' 'MTC' 'STR' 'PIBcomp'};
        roi_info.codes = {
            [1003 2003 1012 2012 1014 2014 1018 2018 1019 2019 1020 2020 1027 2027 1028 2028 1032 2032] % prefrontal cortex
            [1008 2008 1029 2029 1031 2031] % parietal cortex
            [1009 2009 1015 2015 1030 2030 1033 2033 1034 2034] % lateral temporal cortex
            [1011 2011] % lateral occipital cortex
            [1025 2025] % precuneus
            [1002 2002 1026 2026] % anterior cingulate
            [1010 2010 1023 2023] % posterior cingulate
            [17 53 18 54 1006 2006] % medial temporal cortex
            [11 50 12 51] % striatum
            [1003 2003 1012 2012 1014 2014 1018 2018 1019 2019 1020 2020 1027 2027 1028 2028 1032 2032 1009 2009 1015 2015 1030 2030 1033 2033 1034 2034 1008 2008 1029 2029 1031 2031 1025 2025 1002 2002 1026 2026 1010 2010 1023 2023]
            };
    case '[11c]flb'
        roi_info.labels = {'amy' 'cau' 'dacc' 'hip' 'ins' 'nacc' 'oc' 'ofc' 'pal' 'parhip' 'pcc' 'put' 'racc' 'tha'};
                roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [1002 2002] % dacc
            [17 53] % hip
            [1035 2035] % ins
            [26 58] % nacc
            [1012 1014 2012 2014] % ofc
            [1011 2011] % oc
            [13 52] % pal
            [1016 2016] % parhip
            [1023 2023] % pcc
            [12 102 51 111] % put
            [1026 2026] % racc
            [9 10 48 49] % tha
            };
    otherwise
        error('No default roi set defined for %s.\n',tracer);
end

end