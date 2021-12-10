function solveMaze()
    
    myrobot = legoev3('usb');   
    mA = motor(myrobot, 'A');
    mB = motor(myrobot, 'B');

    speed = 50;

    mA.Speed = speed;
    mB.Speed = speed;

    sensor = sonicSensor(myrobot);  
    leftSensor = colorSensor(myrobot, 1);
    middleSensor = colorSensor(myrobot, 3);
    rightSensor = colorSensor(myrobot, 4);
    
    function moveForward()
        start(mA);
        start(mB);
    end
    function setNormalSpeed()
        mA.Speed = speed;
        mB.Speed = speed;
    end
    function stopMotor()
        stop(mA, 1);
        stop(mB, 1); 
    end
    function turnLeft()
        mA.Speed = -speed;
        mB.Speed = speed;
        pause(0.5);
        setNormalSpeed();
    end
    function turnRight()
        pause(0.3);
        mB.Speed = -speed;
        mA.Speed = speed;
        pause(0.5);
        setNormalSpeed();
    end
    function turnArround()
        mA.Speed = -50;
        pause(1);
        mA.Speed = 50;
    end
    function callback = checkForward()
        mA.Speed = speed/2;
        mB.Speed = speed/2;
        pause(0.8);
        middleReflected = readLightIntensity(middleSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        
        if(middleReflected < 60 || rightReflected < 60)
            callback = "Forward";
        else
            callback = "Left";
        setNormalSpeed();
        
        end
    end
    turnsArray = [];  % 0 - left, 1 - forward, 2 - right, 3 - back
    crossIndexes = [];
    currentTurnIndex = 0;
   
    display("Start!");
    moveForward();
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        middleReflected = readLightIntensity(middleSensor, 'reflected');
        distance = readDistance(sensor);
        isLeftBlack = leftReflected < 20;
        isRightBlack = rightReflected < 20;

        isBothYellow = abs(leftReflected-50) < 10 && abs(rightReflected-50) < 10; 
        display(middleReflected);
        display(leftReflected);
        display(rightReflected);
        
        %CALIBRATION
        if(middleReflected > 20)
            %display("Calibrating");
            if(leftReflected < 20)
                mB.Speed = speed/2;
                mA.Speed = 0;
                while 1
                    pause(0.1);
                    middleLight = readLightIntensity(middleSensor, 'reflected');
                   % display("Correct left");
                    if(middleLight < 10)
                        break;
                    end
                end
                %display("Corrected!");
                
                setNormalSpeed();
                
                continue;
            end
            if(rightReflected < 20)
                mB.Speed = 0;
                mA.Speed = speed/2;
                while 1
                    pause(0.1);
                    middleLight = readLightIntensity(middleSensor, 'reflected');
                    %display("Correct right");
                    if(middleLight < 10)
                        break;
                    end
                end

                %display("Corrected!");
                setNormalSpeed();
                continue;
            end
        end
            
        %main logic
        if (isLeftBlack && isRightBlack)
            crossIndexes(end+1) = currentTurnIndex;
            turnsArray(end+1) = 0;
            display("Right turn in cross");
            turnRight();
            continue;
        end

        if(isLeftBlack)
            callback = checkForward();
            if(callback == "Forward")
                turnsArray(end+1) = 1;
                currentTurnIndex = currentTurnIndex + 1;
                
                display("Forward turn");
                setNormalSpeed();
                continue;
            end
            turnsArray(end+1) = 0;
            currentTurnIndex = currentTurnIndex + 1;
            display("Left turn");
            turnLeft();
            
            continue;
        end
        if(isRightBlack)
            currentTurnIndex = currentTurnIndex + 1;
            
            display("Right turn");
            turnRight();
            turnsArray(end+1) = 1;
            continue;
        end 
        
        %if(isBothYellow)
         %   turnArround();
          %  turnArround();
         %   stopMotor();
          %  break;
        %end

        %if(distance < 5)
           % turnArround();
         %   turnsArray = turnsArray([1:crossIndexes(end)]);
          %  crossIndexes = crossIndexes(1:end-1);
           % continue;
        %end
        display("Forward");
    end
    turnIndex = 0;
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        if(rightReflected < 5 || leftReflected < 5)
            switch turnsArray(turnIndex)
                case 0
                    turnLeft();
                case 1
                    moveForward();
                case 2
                    turnRight(true);
                otherwise
                    moveForward();
            end
        end
        turnIndex = turnIndex + 1;
    
                    

        %if(isBothYellow)
         %   turnArround();
          %  turnArround();
           % stopMotor();
           % break;
        %end
    end
end
