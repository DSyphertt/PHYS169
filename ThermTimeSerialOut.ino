const int tempIn = A0;  // Analog input pin
const int numMeasurements = 5000;  // Number of measurements

// Power pins for H-bridge
#define pwmOut1 9
#define pwmOut2 10

// Fixed resistor value in ohms
const float fixedResistance = 100000.0;  // Thermistor's fixed resistance
const float beta = 4540.0;  // Beta parameter for the thermistor
const float R25 = 100000.0;  // Resistance at 25°C
const float T0 = 298.15;  // 25°C in Kelvin

int pwmValue = 0;
int HeatCool = 1;

float Kp = 10.0;  // Proportional control constant
float desiredTemperature = 25.0;  // Initial desired temperature

void setup() {
  Serial.begin(9600);  // Initialize serial communication
  while (!Serial) {
    ;  // Wait for the serial port to connect
  }
}

unsigned long startTime = millis();  // Get the starting time

void loop() {
  // Perform measurements and calculate average
  float total = 0;
  for (int i = 0; i < numMeasurements; i++) {
    int sensorValue = analogRead(tempIn);
    total = total + sensorValue;
  }
  float average = total / (float)numMeasurements;

  // Convert the analog value to voltage
  float voltage = average * (5.0 / 1023.0);  // Assuming 5V reference voltage

  // Calculate the resistance of the thermistor
  float thermistorResistance = (fixedResistance * voltage) / (5.0 - voltage);

  // Calculate the temperature using the Steinhart-Hart equation
  float steinhart = log(thermistorResistance / R25);
  steinhart /= beta;
  steinhart += 1.0 / T0;
  float temperature = 1.0 / steinhart - 273.15;  // Temperature in Centigrade

  // Matlab sends commands over the serial line
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');

    if (command.startsWith("PWM")) {
      sscanf(command.c_str(), "PWM %d", &pwmValue);
    }

    if (command.startsWith("Heat/Cool")) {
      sscanf(command.c_str(), "Heat/Cool %d", &HeatCool);
    }

    if (command.startsWith("DesiredTemp")) {
      sscanf(command.c_str(), "DesiredTemp %f", &desiredTemperature);
    }

    // Adjust PWM based on desired temperature and current temperature
    float temperatureError = desiredTemperature - temperature;
    pwmValue = Kp * temperatureError;

    if (HeatCool == 1) {
      analogWrite(pwmOut1, pwmValue);
      analogWrite(pwmOut2, 0);
    }

    if (HeatCool == 0) {
      analogWrite(pwmOut2, pwmValue);
      analogWrite(pwmOut1, 0);
    }
  }

  // Print average temperature and time in seconds
  unsigned long currentTime = millis();
  float elapsedTime = (currentTime - startTime) / 1000.0;
  Serial.print("Temperature (C): ");
  Serial.print(temperature);
  Serial.print(", Time (s): ");
  Serial.print(elapsedTime);
  Serial.print(", Heat/Cool: ");
  Serial.print(HeatCool);
  Serial.print(", PWM: ");
  Serial.println(pwmValue);
}
