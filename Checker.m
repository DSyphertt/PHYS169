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

% Read and update the strip chart indefinitely
while ishandle(ax)
    % Read data from the serial port
    data = fgetl(ser);
    
    % Check if data is valid (not empty)
    if ~isempty(data)
        % Extract numerical values using regular expressions
        numericValues = str2double(regexp(data, '[-+]?\d*\.?\d+', 'match'));
        
        if ~isempty(numericValues) && numel(numericValues) == 2
            % Add data points to the strip chart
            addpoints(stripChart, numericValues(1), numericValues(2));
            
            % Display the received numerical data with labels
            fprintf('Time: %.2f s, Temperature: %.2f °C\n', numericValues(1), numericValues(2));
            
            % Update the plot
            drawnow limitrate;
        else
            % Display the raw data as is
            disp(['Received data: ' data]);
        end
    end
end

% Close the serial port connection when the figure is closed
fclose(ser);
delete(ser);
clear ser;
