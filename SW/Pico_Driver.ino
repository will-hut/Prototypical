#define SW1   6
#define SW2   7

#define SDA0  8
#define SCL0  9

#define SDA1  14
#define SCL1  15

#include <Adafruit_APDS9960.h>
#include <Adafruit_LSM6DS3TRC.h>

Adafruit_APDS9960 apds;
Adafruit_LSM6DS3TRC lsm;

void setup() {

  pinMode(SW1, OUTPUT);
  digitalWrite(SW1, HIGH);

  Serial.begin(115200);
  while (!Serial);


  Wire.setSDA(SDA0);
  Wire.setSCL(SCL0);

  while (!apds.begin()) {
    Serial.println("Error initializing APDS-9960 sensor!");
    delay(1000);
  }
  while (!lsm.begin_I2C()) {
    Serial.println("Error initializing LSM6DS3 IMU!");
    delay(1000);
  }

  apds.enableProximity(true);
}

void loop() {
  // check if a proximity reading is available

  int proximity = apds.readProximity();

  sensors_event_t accel;
  sensors_event_t gyro;
  sensors_event_t temp;
  lsm.getEvent(&accel, &gyro, &temp);

  Serial.print(proximity);
  Serial.print(",");
  Serial.print(accel.acceleration.x/9.81f);
  Serial.print(",");
  Serial.print(accel.acceleration.y/9.81f);
  Serial.print(",");
  Serial.println(accel.acceleration.z/9.81f);

  delay(10);
}
