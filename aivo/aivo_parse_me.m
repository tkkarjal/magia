function error_message = aivo_parse_me(ME)

error_message = [ char(datetime) ': ' ME.message ' / In function: ' ME.stack(1).name ' @ ' 'line ',num2str(ME.stack(1).line)];

end
