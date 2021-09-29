#include "Oxygen.h"
#include "CO2Sensor.h" //arduino editor package
#include <LiquidCrystal_I2C.h> //arduino editor package

#define ALARMPIN 12 //alarm when below o2min
#define CO2SEN A3
#define WAITCYCLES 5 //amount of cycles it won't send a tone
#define WAITBUTTON 4 
#define WAITLED 13
//oxygen pin A1
//sda A4 scl A5 vcc 5v grd ground

#define CO2MAX 1000 //just a warning not deadly
#define O2MIN 21  //danger alert, %min 19.5

LiquidCrystal_I2C lcd(0x27, 16, 2);
CO2Sensor co2Sensor(CO2SEN, 0.99, 100);

void setup() {
  lcd.init();//initialize LCD
  lcd.clear();
  lcd.backlight();
  lcd.print("calibration");
  Serial.begin(9600);
  pinMode(ALARMPIN, OUTPUT);
  pinMode(WAITBUTTON, INPUT);
  pinMode(WAITLED, OUTPUT);
  co2Sensor.calibrate();
  O2_value();
  lcd.clear();
  lcd.print("finished");
}

int count = 0; //count till alarm active < 0 => active
void loop() {
  if (digitalRead(WAITBUTTON) == 1) {
    count = WAITCYCLES;
    digitalWrite(WAITLED, HIGH);
  }
  float oVal = O2_value(); 
  int coVal = co2Sensor.read();//ppm between 400 - 1000
  //lcd values
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("O2: ");
  lcd.print(oVal);
  lcd.setCursor(0, 1);
  lcd.print("CO2: ");
  lcd.print(coVal);

  //lcd warn + alarm o2
  if (oVal < O2MIN) {
    lcd.setCursor(12, 0);
    lcd.print("warn");
    if (count <= 0) {
      tone(ALARMPIN, 500, 1000);
    }
  }
  if (coVal > CO2MAX) {
    lcd.setCursor(12, 1);
    lcd.print("warn");
  }

  //send data to pc
  Serial.print(coVal);
  Serial.print("c");
  Serial.print(oVal);
  Serial.println("o");
  //see if it's on
  if (count > 0) {
    count--;
  }
  //turn light off if it's not enabled anymore
  if(count <= 0){
    digitalWrite(WAITLED , LOW); 
  }
  delay(1000);
}
