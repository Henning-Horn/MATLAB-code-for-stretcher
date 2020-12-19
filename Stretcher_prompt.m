clear all;
%Arduino details ----------------------------
port = 'COM4'; % port at which your arduino is connected
board = 'Nano'; % model of your arduino board
arduino_board = arduino(port, board, 'Libraries', 'Servo'); %include servo library
linear_motor = servo(arduino_board, 'D9'); % communicate with motor through digital pin 9
%--------------------------------------------
n1=0; % n1 - pause between cycles
nh=0; % nh =0 if no hold requested on stretch, 1 when hold is requested 
j=0; 
k=0;
l=0;
h=0;
g=0;
E_r=0;
%punch holes into pdms at release=0.64
% to increase stretch decrease value lower than 0.64
release=0.64; % release - is non-stretched state of pdms 
%Request user Data

%x1 - Non stretched PDMS- motor lever position
%x2 - Stretched PDMS- motor lever position 
 
writePosition(linear_motor, release); % release PDMS x=0

% Modify PDMS start position
prompt = 'Check PDMS surface flatness, input starting position\n >';
E_release= input(prompt,'s');
E_release=str2double(E_release);

%Write motor new start position for pdms
writePosition(linear_motor, E_release); 
prompt = 'is PDMS surface Flat Y / N \n >';
Flat= input(prompt,'s')

while E_r<1;

        if (strcmp(Flat,'N'))
            prompt = 'Provide new value to adjust PDMS surface flatness\n >';
            E_release= input(prompt,'s');
            E_release=str2double(E_release); 
            writePosition(linear_motor, E_release);
            E_r=0;
            prompt = 'is PDMS surface Flat Y / N \n >';
            Flat= input(prompt,'s')
        elseif (strcmp(Flat,'Y'))
            E_r=1;
        else prompt = 'is PDMS surface Flat Y / N \n >';
            Flat= input(prompt,'s'); E_r=0;
    end 
    
end 

prompt = 'Percent arm movement, arm movment can not exceeding 30%, otherwise PDMS will break\n >';
Percent_Stretch= input(prompt,'s');
Percent_Stretch=str2double(Percent_Stretch)

while i<1;
    
    if (Percent_Stretch<=30) %10.7%   x=2.33mm 
        x1=E_release; x2=E_release-(E_release*(Percent_Stretch/100)); i=1;

    else prompt = 'Percent of arm movement can not exceed 30%, PDMS will break \n >';
        Percent_Stretch= input(prompt,'s')
        Percent_Stretch=str2double(Percent_Stretch)
    end 
end 
% Request user on type of stretch required Fixed or cylic 
prompt = 'Select:     1-Fixed Stretch     2-cyclic Stretch    \n >';
Stretch_type= input(prompt,'s');
type=str2double(Stretch_type)
while l<1;
    if (type==1 | type==2); 
        l=1;
    else prompt = 'INVALID REQUEST: Please Select:     1-Fixed Stretch     2-continuous Stretch    \n >';
        Stretch_type= input(prompt,'s');
        type=str2double(Stretch_type);
    end 
end

prompt = 'Run Time: range (in 5- 720 min) Value in min (180 min - 3hr, 360 min - 6 hr, 540 min -9 hr, 720 min -12hr, 900 min-15 hr)\n >';
Time= input(prompt,'s');
Time=str2double(Time);
while h<1; 
    if Time>=5 && Time<=900; 
        h=1;
    else prompt = 'INVALID REQUEST: Please select Run Time: range (5-720 min)\n >';
    Time= input(prompt,'s');
    Time=str2double(Time);
    end 
end 

prompt = 'Frequency: range (2-4 sec/cycle)\n >';
Frequency= input(prompt,'s');
n1=str2double(Frequency);

while g<1;
    if n1>=2 && n1<=4
        g=1;
    else prompt = 'INVALID REQUEST: please select Frequency: range (2-4 sec/cycle)\n >';
        Frequency= input(prompt,'s');
        n1=str2double(Frequency);
    end 
end 
 % Request user input on Holding Stretch ( YES or NO)
prompt = 'Hold on Stretch for 1 sec (Y/N)\n >';
hold= input(prompt,'s');
while k<1;
    if strcmp( hold,'Y')
        nh=1; k=1; 
    elseif strcmp( hold,'N')
        nh=0; k=1;
    else prompt = 'INVALID REQUEST; Hold on Stretch for 1 sec (Y/N)\n >';
    hold= input(prompt,'s');
    end 
end 
% if user requested FIXED stretch hold stretch for the requested time 
if strcmp( Stretch_type,'1')
    tic;
    while toc<=(Time*60); % loop according to requested time by user in Sec
       writePosition(linear_motor, x2);
    end 
    writePosition(linear_motor, E_release);
    % if user requested CYCLIC stretch hold stretch for the requested time 
elseif strcmp(Stretch_type,'2')
    tic;
    while toc<=(Time*60); % loop according to requested time by user in Sec
       writePosition(linear_motor, x1);
       pause (n1) % Requested Hold time by user 
       writePosition(linear_motor, x2);
       pause (n1+nh)
    end 
    writePosition(linear_motor, E_release); % Stop Motor on non-stretched state 
    toc % Count the time completed in Sec 
    Completed_time=toc/60 % time elapsed in min. 
end 

