function [sport, flag] = initializeArduino( comPort )
if nargin < 1
    comPort = 'COM3';
end
flag = 1;
sport = serial(comPort);
set(sport,'DataBits', 8 );
set(sport,'StopBits', 1 );
set(sport,'BaudRate', 9600);
set(sport,'Parity', 'none');
try
    fopen(sport);
catch
    flag = 0;
end
%%
% pause(1); %% needed
% fprintf(s,['e145' 'd']);
% pause(1);
% fprintf(s,'a45u');
% pause(1);
% fprintf(s,'e13d');
% pause(.1);
% fprintf(s,'a45s');
% %%
% fclose(s);
