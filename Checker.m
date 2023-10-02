% Define the serial port
comPort = '/dev/cu.usbmodem14101'; % Replace with the actual COM port of your Arduino
baudRate = 9600;

% Open the serial port connection
ser = serialport(comPort, baudRate);

% Create a figure for the strip chart
figure;
ax = gca;
stripChart = animatedline('Color', 'b', 'Marker', 'o');
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Temperature Strip Chart');
grid on;

% Initialize arrays for storing data
maxPoints = 100; % Maximum number of data points to display

% Specify the number of iterations to run (or run indefinitely)
numIterations = 100; % Change this to the desired number of iterations

% Read and update the strip chart for a specified number of iterations (or indefinitely)
for iteration = 1:numIterations
    % Read data from the serial port
    data = fgetl(ser);
    
    % Check if data is valid (not empty)
    if ~isempty(data)
        % Extract numerical values using regular expressions
        numericValues = str2double(regexp(data, '[-+]?\d*\.?\d+', 'match'));
        
        if ~isempty(numericValues) && numel(numericValues) == 2
            % Add data points to the strip chart
            addpoints(stripChart, numericValues(1), numericValues(2));
            
            % Update the axes limits
            axis([ax, currentIndex - maxPoints, currentIndex, 0, 40]);
            
            % Display the received numerical data with labels
            fprintf('Time: %.2f s, Temperature: %.2f °C\n', numericValues(1), numericValues(2));
            
            % Update the plot
            drawnow limitrate;
            
            % Increment the index and wrap around if needed
            currentIndex = currentIndex + 1;
            if currentIndex > maxPoints
                currentIndex = 1;
            end
        else
            % Display the raw data as is
            disp(['Received data: ' data]);
        end
    end
end

% Close the serial port connection when done
fclose(ser);
delete(ser);
clear ser;
