function error_message = magia_parse_me(ME)

error_message = [ME.message ' / In function: ' ME.stack(1).name ' @ ' 'line ',num2str(ME.stack(1).line)];

end