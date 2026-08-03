#include <Arduino.h>
#include "pins.h"

namespace {
constexpr unsigned long indicatorTestDelayMs = 500;

void setAllIndicators(unsigned char level) {
  for (unsigned char pin : Pins::statusLeds) {
    digitalWrite(pin, level);
  }

  for (unsigned char pin : Pins::segmentPins) {
    digitalWrite(pin, level);
  }
}

void testIndicator(const char* groupName, unsigned char pin) {
  setAllIndicators(Pins::LED_OFF);
  digitalWrite(pin, Pins::LED_ON);

  Serial.print(groupName);
  Serial.print(" pin ");
  Serial.print(pin);
  Serial.println(" ON");
  delay(indicatorTestDelayMs);
  digitalWrite(pin, Pins::LED_OFF);
}
}

void testHardware() {
  Serial.begin(115200);
  delay(100);

  // Keep the power and gun control lines safe while testing indicators.
  digitalWrite(Pins::gunPower, LOW);
  digitalWrite(Pins::buzzer, LOW);
  digitalWrite(Pins::leftGun, LOW);
  digitalWrite(Pins::rightGun, LOW);

  Serial.println("Starting status LED test");

  for (unsigned char pin : Pins::statusLeds) {
    testIndicator("Status LED", pin);
  }

  Serial.println("Starting 7-segment output test");

  for (unsigned char pin : Pins::segmentPins) {
    testIndicator("Segment", pin);
  }

  setAllIndicators(Pins::LED_OFF);

  constexpr unsigned char switchPins[] = {
      Pins::switch1,
      Pins::switch2,
      Pins::switch3,
      Pins::switch4,
      Pins::switch5,
      Pins::switch6,
      Pins::switch7,
  };

  Serial.println("Reading switch inputs");

    for (unsigned char index = 0;
      index < sizeof(switchPins) / sizeof(switchPins[0]);
      ++index) {
    pinMode(switchPins[index], INPUT);
    Serial.print("Switch ");
    Serial.print(index + 1);
    Serial.print(" (pin ");
    Serial.print(switchPins[index]);
    Serial.print("): ");
    Serial.println(::digitalRead(switchPins[index]) == HIGH ? "HIGH" : "LOW");
  }
}