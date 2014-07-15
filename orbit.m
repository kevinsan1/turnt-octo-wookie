function []=orbit(Az,sport)

% Outputs could be:
% Mode: "turning" or "Not turning" for example.
% Speed
% Axis
% <<<<<<< HEAD
%Rotor azimuth
fprintf(sport, 'L<');
if Az >= 100
    stringAz = num2str(Az,'%-5.2f');
else
    stringAz = ['0' num2str(Az,'%-5.2f')];
end
stringAz = strrep(stringAz, '.', '');


fprintf(sport, ['Pat' stringAz '<']);
fprintf(sport, 'H<');
pause(.5)                   % Wait 50 msec between 'H' & 'G'
fprintf(sport, 'G<');        % Turn CONTROLLER to 'RUN': Start motion
% =======
% Rotor azimuth


% >>>>>>> FETCH_HEAD




% Get the correct format for the orbit unit, satpc32 gives out 1 decimal. 




% Read rotor Azimuth via serial com 



end