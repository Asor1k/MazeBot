function main()
    
    myrobot = legoev3('usb');   
    mA = motor(myrobot, 'A');
    mB = motor(myrobot, 'B');

    mA.Speed = 100;
    mB.Speed = 100;
    
    function moveForward()
        start(mA);
        start(mB);
    end
    function stopMotor()
        stop(mA, 1);
        stop(mB, 1); 
    end
    function turnRight()
        stop(mB, 1);
    end 
    function turnLeft()
        stop(mA, 1);
    end 
    
    sensor = sonicSensor(myrobot);
    distance = readDistance(sensor); %Ultrasonic sensor
    
    leftSensor = colorSensor(myrobot, 1);
    rightSensor = colorSensor(myrobot, 4);
    pause(0.5);
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        
        if leftReflected < 5
            turnLeft();
            pause(0.5);
        elseif rightReflected < 5
            turnRight();
            pause(0.5);
        else 
            moveForward();
        end

        pause(0.1);
    end

end
