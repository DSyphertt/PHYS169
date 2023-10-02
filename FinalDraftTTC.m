% Define the serial port
comPort = '/dev/cu.usbmodem14101'; % Replace with the actual COM port of your Arduino
baudRate = 9600;

% Open the serial port connection
ser = serialport(comPort, baudRate);
fopen(ser);

% Create a figure for plotting
figure;
h = animatedline;
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Temperature vs. Time');
grid on;

% Initialize arrays for storing data
maxPoints = 100; % Number of data points to display
timeData = zeros(1, maxPoints);
temperatureData = zeros(1, maxPoints);

% Initialize index variable
currentIndex = 1;

% Read and plot data in real-time
while ishandle(h)
    % Read data from the serial port
    data = fgetl(ser);
    
    % Check if data is valid (not empty)
    if ~isempty(data)
        % Extract numerical values using regular expressions
        numericValues = str2double(regexp(data, '[-+]?\d*\.?\d+', 'match'));
        
        if ~isempty(numericValues) && numel(numericValues) == 2
            % Store the received numerical data in separate arrays
            timeData(currentIndex) = numericValues(1);
            temperatureData(currentIndex) = numericValues(2);
            
            % Update the plot with time on the x-axis and temperature on the y-axis
            addpoints(h, timeData(currentIndex), temperatureData(currentIndex));
            drawnow limitrate;
            
            % Display the received numerical data with labels
            fprintf('Time: %.2f s, Temperature: %.2f °C\n', numericValues(1), numericValues(2));
            
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
    
    % Add a pause to control the data acquisition rate
    pause(1); % Adjust the pause duration as needed
end

% Close the serial port connection when done
fclose(ser);
delete(ser);
clear ser;
