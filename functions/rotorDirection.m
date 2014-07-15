function [El_mode, El_rotor] = rotorDirection( satElevationValue, comPort )
%ROTORDIRECTION Summary of this function goes here
%   Detailed explanation goes here

El_rotor = getCurrentElevation(comPort);
difference = satElevationValue - El_rotor;
% elevation rotor turns at 2.25 deg/sec
if difference < -4
    dir = 'd'; % down
    El_mode = 'Down';
elseif difference > 4
    dir = 'u';
    El_mode = 'Up';
else
    El_mode = 'Stopped';
    dir = 's';
end
El = num2str(El_rotor);
% Sends arduino 'e' for elevation, El for displaying its current
% elevation, and dir for telling the rotor which direction to
% move.
fprintf(comPort,['e' El dir]);
end

