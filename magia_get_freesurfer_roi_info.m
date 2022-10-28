function roi_info = magia_get_freesurfer_roi_info(specs)

if(strcmp(specs.magia.roi_set,'tracer_default'))
    roi_set = magia_get_tracer_default_roi_set(specs.study.tracer);
else
    roi_set = specs.magia.roi_set;
end

switch roi_set
    case 'rs1'
        roi_info.labels = {'amy' 'cau' 'cer' 'dacc' 'inftemp' 'ins' 'midtemp' 'nacc' 'ofc' 'parsop' 'pcc' 'put' 'racc' 'supfront' 'suptemp' 'tempol' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [8 47] % cer
            [1002 2002] % dacc
            [1009 2009] % inftemp
            [1035 2035] % ins
            [1015 2015] % midtemp
            [26 58] % nacc
            [1012 1014 2012 2014] % ofc
            [1018 2018] % parsop
            [1023 2023] % pcc
            [12 102 51 111] % put
            [1026 2026] % racc
            [1028 2028] % supfront
            [1030 2030] % suptemp
            [1033 2033] % tempol
            [9 10 48 49] % tha
            };
    case 'rs2'
        roi_info.labels = {'amy' 'cau' 'cer' 'dacc' 'hip' 'inftemp' 'ins' 'medul' 'midbr' 'midtemp' 'nacc' 'ofc' 'pal' 'parsop' 'pcc' 'pons' 'put' 'racc' 'supfront' 'suptemp' 'tempol' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [8 47] % cer
            [1002 2002] % dacc
            [17 53] % hip
            [1009 2009] % inftemp
            [1035 2035] % ins
            [175] % medul
            [173] % midbr
            [1015 2015] % midtemp
            [26 58] % nacc
            [1012 1014 2012 2014] % ofc
            [13 52] % pal
            [1018 2018] % parsop
            [1023 2023] % pcc
            [174] % pons
            [12 102 51 111] % put
            [1026 2026] % racc
            [1028 2028] % supfront
            [1030 2030] % suptemp
            [1033 2033] % tempol
            [9 10 48 49] % tha        
            };
    case 'rs3'
        roi_info.labels = {'amy' 'cau' 'nacc' 'pal' 'put' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [26 58] % nacc
            [13 52] % pal
            [12 102 51 111] % put
            [9 10 48 49] % tha
            };
    case 'rs4'
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
    case 'rs5'
        roi_info.labels = {'amy' 'cau' 'dacc' 'hip' 'ins' 'nacc' 'ofc' 'parhip' 'pcc' 'pcun' 'put' 'racc' 'tha'};
        roi_info.codes = {
            [18 54] % amy
            [11 50] % cau
            [1002 2002] % dacc
            [17 53] % hip
            [1035 2035] % ins           
            [26 58] % nacc
            [1012 1014 2012 2014] % ofc
            [1016 2016] % parhip
            [1023 2023] % pcc
            [1025 2025] % pcun
            [12 102 51 111] % put
            [1026 2026] % racc
            [9 10 48 49] % tha
            };
    case 'rs6'
        roi_info.labels = {'CGA' 'CGP' 'LOC' 'LTC' 'MTC' 'PARCALL' 'PIB1PFCALL' 'PIBcomp' 'PREC' 'STR' 'CER'};
        roi_info.codes = {
            [1002 2002 1026 2026] % anterior cingulate
            [1010 2010 1023 2023] % posterior cingulate
            [1011 2011] % lateral occipital cortex
            [1009 2009 1015 2015 1030 2030 1033 2033 1034 2034] % lateral temporal cortex
            [17 53 18 54 1006 2006] % medial temporal cortex
            [1008 2008 1029 2029 1031 2031] % parietal cortex
            [1003 2003 1012 2012 1014 2014 1018 2018 1019 2019 1020 2020 1027 2027 1028 2028 1032 2032] % prefrontal cortex
            [1003 2003 1012 2012 1014 2014 1018 2018 1019 2019 1020 2020 1027 2027 1028 2028 1032 2032 1009 2009 1015 2015 1030 2030 1033 2033 1034 2034 1008 2008 1029 2029 1031 2031 1025 2025 1002 2002 1026 2026 1010 2010 		 1023 2023] % pibcomp
            [1025 2025] % precuneus
            [11 50 12 51] % striatum
            [8 47] % cerebellum
            };
    case 'rs7'
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
     case 'striat_unil'
        roi_info.labels = {'cau_l' 'cau_r' 'nacc_l' 'nacc_r' 'pal_l' 'pal_r' 'put_l' 'put_r' 'tha_l' 'tha_r'};
        roi_info.codes = {
            11 % cau_l
            50 % cau_r
            26 % nacc_l
            58 % nacc_r
            13 % pal_l
            52 % pal_r
            [12 102] % put_l
            [51 111] % put_r
            [9 10 ] %tha_l
            [48 49] % tha_r
            };
    case 'rs_CB1R_new'
        roi_info.labels = {'amy' 'hip' 'cau' 'put' 'nacc' 'tha' 'cer' 'acc' 'pcc' 'ins' 'ofc' 'suptemp' 'midtemp' 'inftemp' 'supfront' 'midbr' 'pons' 'medul' 'entorhinal' 'pallidum' 'midfront' 'cingulate'};
        roi_info.codes = {
            [18 54] % amy
            [17 53] % hip
            [11 50] % cau
            [12 102 51 111] % put
            [26 58] % nacc
            [9 10 48 49] % tha 
            [8 47] % cer
            [1002 2002 1026 2026] % dacc + racc = acc
            [1023 2023] % pcc
            [1035 2035] % ins    
            [1012 1014 2012 2014] % ofc
            [1030 2030] % suptemp
            [1015 2015] % midtemp
            [1009 2009] % inftemp
            [1028 2028] % supfront
            [173] % midbr
            [174] % pons
            [175] % medul
            [1006 2006 ] % entorhinal cortex
            [13 52] % pallidum
            [1003 1027 2003 2027] % middle frontal   
            [1002 2002 1026 2026 1023 2023 1010 2010] % cingulate = acc + pcc + isthmus
            };
        
     case 'FSlobes'
        roi_info.labels = {'fro' 'par' 'tmp' 'occ' 'cin' 'cau' 'put' 'tha' 'hip' 'amy' 'ins' 'pal' 'bs' 'cc' 'cer' 'WM' 'GMctx' 'Brain'}; %see freesurfer cortical lobe parcellation: https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation
        roi_info.codes = {
            [   1028        2028        1027        2027        1003        2003        1018        2018        1020        2020        1019        2019 ...
                1014        2014        1012        2012        1024        2024        1017        2017        1032        2032] % frontal lobe
            [  1029        2029        1008        2008        1031        2031        1022        2022        1025        2025 ] %parietal lobe
            [  1009        2009        1015        2015        1030        2030        1001        2001        1007        2007        1034        2034 ...
               1006        2006        1033        2033        1016        2016] %temporal lobe
            [  1011        2011        1013        2013        1005        1025        2005        2025        1021        2021 ] %occipital lobe
            [  1002        2002        1026        2026        1010        2010        1023        2023 ] %cingulate (included as a lobe)
            [11 50] % cau
            [12 102 51 111] % put
            [9 10 48 49] % tha
            [17 53] % hip
            [18 54] % amy
            [1035 2035] % ins
            [13 52] % pallidum
            [16] %brain stem
            [251 252 253 254 255] %corpus callosum
            [8 47] % cer
            [2 41] %cerebral WM
            [1000	1001	1002	1003	1005	1006	1007	1008	1009	1010	1011	1012	1013	... 
             1014	1015	1016	1017	1018	1019	1020	1021	1022	1023	1024	1025	1026	1027 ...
        	 1028	1029	1030	1031	1032	1033	1034	1035	2000	2001	2002	2003	2005	2006 ...
        	 2007	2008	2009	2010	2011	2012	2013	2014	2015	2016	2017	2018	2019	2020 ...
        	 2021	2022	2023	2024	2025	2026	2027	2028	2029	2030	2031	2032	2033	2034 ...
        	 2035]; %cortical GM
            [2	7	8	10	11	12	13	16	17	18	26	28	30	41	46	47	49	50	51	52	53	54	58	60	62	77	80	85	... 
             251	252	253	254	255	1000	1001	1002	1003	1005	1006	1007	1008	1009	1010	1011	... 
             1012	1013	1014	1015	1016	1017	1018	1019	1020	1021	1022	1023	1024	1025	... 
             1026	1027	1028	1029	1030	1031	1032	1033	1034	1035	2000	2001	2002	2003	...
             2005	2006	2007	2008	2009	2010	2011	2012	2013	2014	2015	2016	2017	2018	...
             2019	2020	2021	2022	2023	2024	2025	2026	2027	2028	2029	2030	2031	2032	...
             2033	2034	2035]; %brain
            };
    otherwise
        error('The roi_set %s has not been defined. Please use another roi_set.',roi_set);
end
end
