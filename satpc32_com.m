function  [chan, flag ] = satpc32_com
flag = 1;
try
    chan = ddeinit('SatPC32', 'SatPcDdeConv');
catch
    chan = lasterr;
    flag = 0;
end
end
