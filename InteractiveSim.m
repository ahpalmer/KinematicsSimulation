function RoboHAZMAT = InteractiveSim(RoboHAZMAT)

attempt = 0;
interactiveSim = input('Begin Interactive Simulation? [Y/N]: ','s');

% Allow for 3 attempts to enter the interactive simulation mode by entering
% in [Y/y/ ] or to voluntarily quit by entering [N/n]
while (~strcmpi(interactiveSim,'yes') && ~strcmpi(interactiveSim,'no')...
        && ~strcmpi(interactiveSim,'y') && ~strcmpi(interactiveSim,'n')...
        && ~strcmpi(interactiveSim,''))
    attempt = attempt + 1;
    if (attempt == 3)
        fprintf('\nFinal attempt...');
    elseif (attempt == 4)
        fprintf(['\nUnrecognized Command. Too many failed attempts.',...
            '\nQuitting Simulation...']);
        break;
    end
    fprintf('\nUnrecognized command, please enter [Y/N]\n');
    interactiveSim = input('Begin Interactive Simulation? [Y/N]: ','s');
end

% If the user chose to enter the interactive simulation mode, begin
if (strcmpi(interactiveSim,'yes') || strcmpi(interactiveSim,'y'))
    fprintf('\nBeginning Interactive Simulation...\n');
    while (strcmpi(interactiveSim,'yes') || strcmpi(interactiveSim,'y'))
        fprintf('\nChoose Kinematic Chain to move.\n');
        fprintf('Options are:\n');
        fields = fieldnames(RoboHAZMAT.KinematicChains);
        for i = 1:length(fields)
            fprintf([' ',fields{i},'\n']);
        end
        KCstring = input(' > ','s');
        valid = false;
        
        for i = 1:length(fields)
            if (strcmpi(KCstring, fields{i}))
                valid = true;
                KCname = fields{i};
                KC = RoboHAZMAT.KinematicChains.(fields{i});
            end
        end
        if (valid)
            fprintf([KCstring,' was selected\n']);
            fprintf('\nChoose (x, y, z) location to move the gripper to.\n');
            x = input(' x = ');
            y = input(' y = ');
            z = input(' z = ');
            
            pointsd = zeros(4, size(KC.points.p,2));
            pointsd(:,4) = [-.2162;0.1087;0.2093;1];
            %pointsd(:,4) = [0;-0.1790;0.0920;1];
            pointsd(:,size(KC.points.p,2)) = [x;y;z;1];
            X = optimize(RoboHAZMAT,KCname,pointsd);
            
            KC = RotateKinematicChain(KC,X);
            RoboHAZMAT.KinematicChains.(KCname) = KC;
            
            RobotPlot(RoboHAZMAT);
            
            serialObjIMU = SetupSerial();
            
            while (1)
                [yaw, pitch, roll, readingIMU] = ReadIMU(serialObjIMU);
                if (~isnan(readingIMU))
                    X = zeros(6,1);
                    X(2,1) = (-(yaw))/180*pi;
                    X(4,1) = (-(pitch + 90))/180*pi;
                
                    KC = RotateKinematicChain(KC,X);
                    RoboHAZMAT.KinematicChains.(KCname) = KC;
                    RobotPlot(RoboHAZMAT);
                    drawnow;
                end
            end
        else
            fprintf(['\nInvalid Kinematic Chain name. Please choose',...
                'from the list\n']);
        end
        
        attempt = 0;
        interactiveSim = 'a';
        while (~strcmpi(interactiveSim,'yes') && ...
                ~strcmpi(interactiveSim,'no') && ...
                ~strcmpi(interactiveSim,'y') && ...
                ~strcmpi(interactiveSim,'n') && ...
                ~strcmpi(interactiveSim,''))
            attempt = attempt + 1;
            if (attempt == 3)
                fprintf('\nFinal attempt...');
            elseif (attempt == 4)
                fprintf(['\nUnrecognized Command. Too many failed ',...
                    'attempts.\nQuitting Simulation...']);
                interactiveSim = 'n';
                break;
            end
            if (attempt > 1)
                fprintf('\nUnrecognized command, please enter [Y/N]\n');
            end
            interactiveSim = input('\nContinue Interactive Simulation? [Y/N]: ','s');
        end
    end
    % Otherwise, quit the simulation
elseif (strcmpi(interactiveSim,'no') || strcmpi(interactiveSim,'n')...
        || strcmpi(interactiveSim,''))
    fprintf('\nQuitting Simulation...\n');
end