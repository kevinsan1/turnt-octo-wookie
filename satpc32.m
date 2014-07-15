% **************** SatPc32 - Matlab Interface ************
% Works via DDE, SatPC32 will respond with the string ** NO SATELLITE ** if
% the elevation is less than zero. This can be fixed, see documenation for DDE in SatPc32. 

function [Az, El, Sat] = satpc32(chan)
%chan = ddeinit('SatPC32', 'SatPcDdeConv');
data = ddereq(chan, 'SatPcDdeItem',[1,1]);


% SatPC delivers a string with the following strucutre: 
%SNJUGNU AZ16.3 EL-48.4 UP0 UM DN0 DM MA132.0

key1   = 'AZ';
key2 ='EL';
key3 = 'SN'; %For satellite name
Index1 = strfind(data, key1);
Index2 = strfind(data, key2);
Index3 = strfind(data, key3);
Az = sscanf(data(Index1(1) + length(key1):end), '%g', 1);
El = sscanf(data(Index2(1) + length(key2):end), '%g', 1) ;     
Sat = sscanf(data(Index3(1) + length(key3):end), '%s', 1);  

end 