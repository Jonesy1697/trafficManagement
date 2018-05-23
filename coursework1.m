function coursework1()
%input will be 2 images, these images can be the same
    clear all;

    %-----------------------------------
    % Load cars into array
    %-----------------------------------

    N = 14;
    cars = cell(N,4);

    cars{1,4} = imread('001.jpg');
    cars{2,4} = imread('002.jpg');
    cars{3,4} = imread('003.jpg');
    cars{4,4} = imread('004.jpg');
    cars{5,4} = imread('005.jpg');
    cars{6,4} = imread('006.jpg');
    cars{7,4} = imread('007.jpg');
    cars{8,4} = imread('008.jpg');
    cars{9,4} = imread('009.jpg');
    cars{10,4} = imread('010.jpg');
    cars{11,4} = imread('011.jpg');
    cars{12,4} = imread('fire01.jpg');
    cars{13,4} = imread('fire02.jpg');
    cars{14,4} = imread('oversized.jpg');
    
    %-----------------------------------
    % Locate car 
    %-----------------------------------

    for i = 1:N
        %Filter noise with gaussian filter
        carValue = 140;
        detectedCar = rgb2gray(cars{i,4});
        detectedCar = imextendedmax(detectedCar, carValue);

        se1 = strel('square', 25);       
        noSmallStructures = imclose(detectedCar, se1);  % Close the image
        cars{i,1} = imcomplement(noSmallStructures);      % Invert the colours
        
        stats = regionprops(cars{i,1}, 'ConvexArea',  'Centroid');    
        % Bounding box for width
        % Use pythag (Distance of car with height) to calculate distance
            % from camera
        % w1/h = tan(angle)
            %w1 = width
            %h = distance from camera
            % angle = difference of angle in width of car
            
        %Assign one set of stats for each image
        if length([stats.ConvexArea]) > 1
            area = [stats.ConvexArea];
            cars{i,2} = area(2);
            center = [stats.Centroid];
            cars{i,3} = [center(3), center(4)];
        else
            area = [stats.ConvexArea];
            cars{i,2} = area(1);
            center = [stats.Centroid];
            cars{i,3} = [center(1), center(2)];
        end
    end

    %-----------------------------------
    % Calculate speed
    %-----------------------------------

    target = cars(1,1:4);
    target2 = cars(2,1:4);
    numbOfFrames = 2;
    interval = (numbOfFrames * 0.1) - 0.1;

    distanceY = target{3}(2) - target2{3}(2);   % pixel difference
    distanceY = distanceY/60;
    speed = distanceY/interval;   % pixels per second

    %-----------------------------------
    % Calculations
    % 
    % Any vehicle exceeding 2.5 meters in width
    %          or faster than 30mph is diverted
    % Fire engines are exempt
    %-----------------------------------

    %7Tan60 will be the center of the camera
    %Calulate from this with pixel calculation the difference of angles
        % angleChange = pixelNum * pixelAngle
        % Distance = 7Tan(angle-angleChange)
        % Multiply be 10 for MetersPerSecond
    
    if (target{2} > 50000 & target{4}(uint8(target{3})) == [133,134]) %#ok<BDSCA,AND2>
       disp("Fire engine");
    elseif (target{2} > 35000)
       disp("Oversized");
    else    
        if speed < 30
            disp("Size OK");
        else 
            disp("Speeding");    
        end
    end
end
