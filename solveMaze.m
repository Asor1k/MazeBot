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
        pause(0.6);
        setNormalSpeed();
    end
    function turnRight()
        pause(0.4);
        mB.Speed = -speed;
        mA.Speed = speed;
        pause(0.6);
        setNormalSpeed();
    end
    function turnArround()
        mA.Speed = -50;
        pause(1.15);
        mA.Speed = 50;
    end
    function callback = checkForward()
        mA.Speed = speed/2;
        mB.Speed = speed/2;
        pause(0.8);
        middleReflected = readLightIntensity(middleSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        display("fsedfs");
        
        timerVal = 0;

       while timerVal < 0.25
            mA.Speed = -speed/3;
            mB.Speed = speed/3;
            middleReflected = min(readLightIntensity(middleSensor, 'reflected'), middleReflected);
            pause(0.05);
            timerVal = timerVal + 0.05;
       end
        while timerVal < 0.75
            mA.Speed = speed/3;
            mB.Speed = -speed/3;
            middleReflected = min(readLightIntensity(middleSensor, 'reflected'), middleReflected);
            pause(0.05);
            timerVal = timerVal + 0.05;
        end
       while timerVal < 1
            mA.Speed = -speed/3;
            mB.Speed = speed/3;
            middleReflected = min(readLightIntensity(middleSensor, 'reflected'), middleReflected);
            pause(0.05);
            timerVal = timerVal + 0.05;
       end  
        display(middleReflected);

        if(middleReflected < 60 || rightReflected < 60)
            callback = "Forward";
        else
            callback = "Left";
        setNormalSpeed();
        
        end
    end
    turnsArray = [2,0,0,2,1,2,2,1];  % 0 - left, 1 - forward, 2 - right, 3 - back
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
        colorLeft = readColor(leftSensor);
        colorRight = readColor(rightSensor);
        isBothYellow =  colorRight == "yellow" && colorLeft == "yellow";
        display(middleReflected);
        display(leftReflected);
        display(rightReflected);

        %CALIBRATION

        setNormalSpeed();
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

        if(isBothYellow)
           stopMotor();
          break;
        end
        distance = readDistance(sensor);
        if(distance < 0.1)
            turnArround();
            display("Turn around");
               turnsArray = turnsArray([1:crossIndexes(end)]);
               crossIndexes = crossIndexes(1:end-1);
            continue;
        end
        if(middleReflected > 20)
            display("\");
            stored = middleReflected;
            mA.Speed = 30;%A - left
            pause(0.2);
            middleReflected = readLightIntensity(middleSensor, 'reflected');
            if (stored < middleReflected)
                mB.Speed = 10;
                timer = 0;
                flag = false;
                while middleReflected > 20
                    mA.Speed = 30;
                    middleReflected = readLightIntensity(middleSensor, 'reflected');
                    timer = timer + 0.05;
                    pause(0.05);
                    if (timer > 0.3)
                        flag = true;
                        break;
                    end
                end
                if(flag)
                    while middleReflected > 20
                        mB.Speed = 30;
                        mA.Speed = 10;
                        middleReflected = readLightIntensity(middleSensor, 'reflected');
                        timer = timer + 0.05;
                        pause(0.05);
                        if (timer > 0.5)
                            flag = true;
                            break;
                        end
                    end
                end
            end
            setNormalSpeed();
        end
        display("Forward");
    end
turnIndex = 1;
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        if(rightReflected < 20 || leftReflected < 20)
            switch turnsArray(turnIndex)
                case 0
                    pause(0.4)
                    turnLeft();
                case 1
                    moveForward();
                    setNormalSpeed();
                case 2
                    turnRight();
                otherwise
                    moveForward();
                    setNormalSpeed();
            end

        turnIndex = turnIndex + 1;
        end
    
                    

        if(turnIndex == 9)
            turnArround();
            turnArround();
            stopMotor();
           break;
        end
    end
end
