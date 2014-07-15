function currentElevation = getCurrentElevation(comPort)
%  	Description
%	currentElevation = getCurrentElevation(comPort)
%   comPort = fopen(serial('COM4')), already opened in another function

fprintf(comPort, 'r'); % tell arduino to analogread
pause(0.1);
elevationInBits = str2num(fgets(comPort)); % read in value
currentElevation = elevationInBits * 180/960; % convert to degrees

end % function
