%%%%%%% Arduino controller %%%%%%%%%%%%%%
% This files decides whether the rotor goes up or down <=>  pins low (0)
% or high (1). 


% Arduino object is currently 'a'

function [El_rotor, El_mode]=yaseu(El,object)

% Constants %%%%%%%%%%%%%%%%%%%%%55

%elAdZeroOffset   =   0;  % adjust to zero out lcd el reading when control box el = 0


% Declare PINS HAVE THESE NOT IN THE LOOP! Change to a more efficient
% position
a = object;
el_input_pin = 1; %A1 not required, pinmode not required.   
el_up_pin = 8;
el_down_pin = 9;

a.pinMode(el_up_pin , 'OUTPUT')
a.pinMode(el_down_pin , 'OUTPUT')

El_voltage = a.analogRead(el_input_pin);
El_rotor = (180/923)*El_voltage;


% Code so that analogread translates into a current Elevation degree called
% rotor_El. 


if El_rotor ~= El
    if El_rotor < El
        a.digitalWrite(el_up_pin, 1) % 1 <=> go high
        a.digitalWrite(el_down_pin, 0)
        El_mode = 'Going up';
    else 
        a.digitalWrite(el_up_pin, 0)
        a.digitalWrite(el_down_pin, 1) 
        El_mode = 'Going down';
    end
    %disp('Elevation is already correct')
    
end 