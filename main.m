function main()
    
    myrobot = legoev3('usb');   
    mA = motor(myrobot, 'A');
    mB = motor(myrobot, 'B');

    mA.Speed = 50;
    mB.Speed = 50;
    
    function moveForward()
        start(mA);
        start(mB);
    end
    function stopMotor()
        stop(mA, 1);
        stop(mB, 1); 
    end
    function turnRight()
        pause(0.3);
        mB.Speed = -52;
        mA.Speed = 50;
        pause(0.5);
        mB.Speed = 52;
    end 
    function turnLeft()
        pause(0.3);
        mA.Speed = -50;
        mB.Speed = 52;
        pause(0.5);
        mA.Speed = 50;
    end 
    
    sensor = sonicSensor(myrobot);
    distance = readDistance(sensor); %Ultrasonic sensor
    
    leftSensor = colorSensor(myrobot, 1);
    rightSensor = colorSensor(myrobot, 4);
    pause(0.5);
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        display(leftReflected + " " + rightReflected);
        if leftReflected < 25
            turnLeft();
        elseif rightReflected < 25
            turnRight();
        else 
            moveForward();
        end
    end

end
