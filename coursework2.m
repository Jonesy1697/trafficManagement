function coursework2(inputCar1, inputCar2)
    %-----------------------------------
    % Input will be 2 images.
    % Function call must be in the format coursework('name', 'name') where 
    % name is the image name. E.G. coursework('001.jpg', '003.jpg')
    % To call the same image, enter the file name twice when calling the
    % function. E.G. coursework('001.jpg', '001.jpg')
    %-----------------------------------
    
    % Set up cell to store cars
    N = 2;
    cars = cell(N,5);
    cars{1,5} = imread(inputCar1);
    cars{2,5} = imread(inputCar2);
    %cars{1,5} = imread('003.jpg');   
    
    % Set up camera variables
    frameInteval = 0.1;
    pixelAngle = 0.042;
    cameraCenterY = 240;
    cameraAngle = 60;
    cameraHeight = 7;
    
    %For every car in cell cars
    for i = 1:N
        
        locateCar(i);

        % viewCar(i); % Used for testing only
        
    end
    
    speed = detectSpeed();
    size = detectSize();
    fireEngine = detectFireEngine();
    
    disp("Speed: " + speed + "mph");
    disp("Size: " + size + "m");
    
    disp(" ");
    
    if ~fireEngine
        if speed > 30
            disp("Speeding vehicle");
        end
    
        if size > 2.5
            disp("Oversized");
        end
    end
    
    %-----------------------------------
    % For a given image, apply the filters, and then save new image in
    % cars(i,1), where i is the image number
    %
    % Values of the car will be added to cells 2-4, storing centroid,
    % bounding box and the area of the detected car
    %-----------------------------------
    function locateCar(i)
    
        carValue = 140;
        cars{i,1} = rgb2gray(cars{i,5});
        cars{i,1} = imextendedmax(cars{i,1}, carValue);
        
        se1 = strel('square', 25);       
        cars{i,1} = imclose(cars{i,1}, se1);    %Opening
        se = strel('square', 50);       
        cars{i,1} = imerode(cars{i,1}, se);          %Closing
        
        g = fspecial('gaussian',[25,25],15);            
        cars{i,1} = edge(cars{i,1}, 'zerocross', g);        %Apply Gaussian filter
        
        stats = regionprops(cars{i,1}, 'ConvexArea', 'Centroid', 'BoundingBox');        %Get values of detected objects

        cars{i,2} = [stats.BoundingBox];
        cars{i,3} = [stats.ConvexArea];
        cars{i,4} = [stats.Centroid];  
        
        if (length(cars{i,2}) > 1)      %Ensure that the car is the only values that are stored in cars details
            cars{i,2} = [cars{i,2}(length(cars{i,2})-3), ...
                        cars{i,2}(length(cars{i,2})-2), ...
                        cars{i,2}(length(cars{i,2})-1), ...
                        cars{i,2}(length(cars{i,2}))];
            cars{i,3} = cars{i,3}(length(cars{i,3}));
            cars{i,4} = [cars{i,4}(length(cars{i,4})-1), ...
                        cars{i,4}(length(cars{i,4}))];
        end

    end
    
    %-----------------------------------
    % Not required, only for testing of car detection to ensure the correct
    % object has been detected.
    %-----------------------------------
    function viewCar(i)
        
        centerX = cars{i,4}(1);
        centerY = cars{i,4}(2);
        figure, imshow(cars{i,1}), hold on;   
        x = [centerX - 10,centerX + 10];
        y = [centerY, centerY];
        plot(x,y,'LineWidth',1, 'Color',[1, 0.0, 0.0]);
        x = [centerX, centerX];
        y = [centerY - 10, centerY + 10];
        plot(x,y,'LineWidth',1, 'Color',[1, 0.0, 0.0]);

    end

    %-----------------------------------
    % Detect if a car is going over the speed limit from the two images.
    %-----------------------------------
    function speed = detectSpeed()
            
        % Calculate distance from center
        yDistanceFromCenter1 = (cars{1,4}(2) - cameraCenterY);
        yDistanceFromCenter2 = (cars{2,4}(2) - cameraCenterY);   

        %Calculate angle of the distance
        positionY1 = cameraHeight * ...
                        tand(cameraAngle - ...
                        (yDistanceFromCenter1 * pixelAngle));
        positionY2 = cameraHeight * ...
                        tand(cameraAngle - ...
                        (yDistanceFromCenter2 * pixelAngle));

        %Calculate speed
        yDifference = positionY2 - positionY1;
        speed = (yDifference / frameInteval) * 2.2369;   % Conversion of m/s to mph
    end

    %-----------------------------------
    % Detect if a car is oversized, width of over 2.5 meters.
    %-----------------------------------
    function size = detectSize()
        
        pixelWidth = (cars{1,2}(3) - cars{1,2}(1))  * pixelAngle;
        
        % Calculate distance from center
        yDistanceFromCenter = (cars{1,4}(2) - cameraCenterY);

        %Calculate angle of the distance
        positionY = cameraHeight * ...
                        tand(cameraAngle - ...
                        (yDistanceFromCenter * pixelAngle));
        
        cameraDistance = sqrt(positionY^2 + 7^2);
        
        size = 2 * cameraDistance * tand(pixelWidth);
                    
    end
    
    %-----------------------------------
    % Detect if a given car is a fire engine, by the size ratio and sample
    % colours.
    %-----------------------------------
    function fireEngine = detectFireEngine()
       
        bottomY =  (cameraCenterY * 2) - cars{1,4}(2);
        topY = (cameraCenterY * 2) - cars{1,2}(2);
        
        bottomLength = cameraHeight*tand(bottomY * pixelAngle);
        topLength = cameraHeight*tand(cameraAngle - topY * pixelAngle);
        
        length = topLength - bottomLength;
        
        if (length > size*2 && length < size*4)
            location = uint8(cars{4});
            location = uint8([location(1), location(2) + 40]);
            
            if cars{1, 5}(location) == [149, 143] 
                fireEngine = true;
                disp("Fire Engine"); 
            else
                fireEngine = false;
            end
            
        else
            fireEngine = false;
        end
        
    end
    
end