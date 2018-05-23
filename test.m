function coursework3(inputCar1, inputCar2)
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

        %viewCar(i); % Used for testing only
        
    end
    
    speed = detectSpeed();
    width = detectSize();
    fireEngine = detectFireEngine();
    
    disp("Speed: " + speed + "mph");
    disp("Size: " + width + "m");
    
    disp(" ");
    
    if ~fireEngine
        if speed > 30
            disp("Speeding vehicle");
        end
    
        if width > 2.5
            disp("Oversized");
        end
    end
    
    %-----------------------------------
    % For a given image, apply the filters, and then save new image in
    % cars(i,1), where i is the image number
    %
    % Values of the car will be added to cells 2-4, storing centroid,
    % bounding box and the area of the detected car
    %
    % Not effective for all images, such as image 8
    %-----------------------------------
    function locateCar(i)
    
        im = cars{i,5};
        original = im;

        carValue = 140;
        im = rgb2gray(im);
        im = imextendedmax(im, carValue);        
        se1 = strel('square', 25);       
        im = imclose(im, se1);    %Opening
        se = strel('square', 50);       
        im = imerode(im, se);          %Closing        
        g = fspecial('gaussian',[25,25],15);            
        im = edge(im, 'zerocross', g);        %Apply Gaussian filter        
        stats = regionprops(im, 'Centroid', 'BoundingBox');        %Get values of detected objects
        bounding = [stats.BoundingBox];
        center = [stats.Centroid];  

        if (length(bounding) > 1)      %Ensure that the car is the only values that are stored in cars details
            center = [center(length(center)-1), ...
                center(length(center))];
        end

        centroid = center;  

        centerX = centroid(1);
        centerY = centroid(2);

        xBoundary = centerX - 1;
        yBoundary = centerY - 30;
        xBoundary1 = centerX + 1;
        yBoundary1 = centerY - 31;

        x = [xBoundary, xBoundary1, xBoundary1, xBoundary];
        y = [yBoundary1, yBoundary1, yBoundary,yBoundary];

        im = original;

        mask = roipoly(im, x, y);
        red = immultiply(mask, im(:,:,1));
        green = immultiply(mask, im(:,:,2));
        blue = immultiply(mask, im(:,:,3));
        g = cat(3, red, green, blue);
        [M,N,K] = size(g);
        I = reshape(g, M*N, 3);
        idx = find(mask);
        I = double(I(idx,1:3));
        [C,m] = covmatrix(I);

        t = 75;
        seg = colorseg('euclidean', im, t, m);

        stats = regionprops(seg, 'Centroid', 'BoundingBox');        %Get values of detected objects
        cars{i,1} = seg;
        cars{i,4} = [stats.Centroid];  
        cars{i,2} = [stats.BoundingBox];  
        
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
    function width = detectSize()
        
        % Edge to object center
        pixelWidth = (cars{1,2}(3) - cars{1,4}(1))  * pixelAngle;
        
        if pixelWidth < 0
            pixelWidth=pixelWidth*-1;
        end
                
        yDistanceFromCenter = (cars{1,4}(2) - cameraCenterY);   

        %Calculate Y distance
        positionY = cameraHeight * ...
                tand(cameraAngle - (yDistanceFromCenter * pixelAngle));
                    
        width = 2 * positionY * tand(pixelWidth);
                    
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
        
        if (length < width*3)
            img = cars{1,5};
            red = img(:,:,1);
            green = img(:,:,2);
            blue = img(:,:,3);
            rMask = red > 200;
            gMask = green < 50;
            bMask = blue < 50;
            redObjectMask = uint8(rMask & gMask & bMask); 
            isored = zeros(size(redObjectMask),'uint8');
            isored(:,:,1) = img(:,:,1) .* redObjectMask;
            isored(:,:,2) = img(:,:,2) .* redObjectMask;
            isored(:,:,3) = img(:,:,3) .* redObjectMask;
            bwImage = im2bw(isored,0);
            imshow(bwImage);
                sum(bwImage(:) == 1)                    
            if sum(bwImage(:) == 1) > 20000 
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
