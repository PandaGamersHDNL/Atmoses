#include "Oxygen.h"

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println("Calibration sensor...This needs one minute");
  O2_value();
  Serial.println("Finish Calibration");
}

void loop() {
  // put your main code here, to run repeatedly:
  float O2 = 0;
  O2 = O2_value();
  Serial.print("The percentage of oxygen is:");
  Serial.print(O2);
  Serial.println("%");
  delay(1000);
}
