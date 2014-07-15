%%%% Establish connection with arduino %%%%%
%%%% Commands are based on the MATLAB Interface for Arduino. 

%Make sure that the right port is used and that the arduino has the
%required sketch uploaded to it and that the arduino_install.m has been
%used once. 

function  [a]=yaseu_com();

% Create arduino object and connect to board
    if exist('a','var') && isa(a,'arduino') && isvalid(a),
        % nothing to do    
        else
            a=arduino('COM3');
     end
end 
   

