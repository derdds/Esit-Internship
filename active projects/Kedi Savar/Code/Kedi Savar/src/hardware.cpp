#include <Arduino.h>
#include <esp_sleep.h>
#include "app_state.h"
#include "hardware.h"
#include "pins.h"

void initializeHardware() {
  const unsigned char inputs[] = {Pins::relayTrigger, Pins::switch7, Pins::switch6,
                                  Pins::switch5, Pins::switch4, Pins::switch3,
                                  Pins::switch2, Pins::switch1, Pins::batteryAdc};
  for (unsigned char pin : inputs) pinMode(pin, INPUT);

  const unsigned char outputs[] = {Pins::gunPower, Pins::buzzer, Pins::leftGun,
                                   Pins::rightGun};
  for (unsigned char pin : outputs) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);
  }
  for (unsigned char pin : Pins::statusLeds) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, Pins::LED_OFF);
  }
  for (unsigned char pin : Pins::segmentPins) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, Pins::LED_OFF);
  }
}

void handleWakeReason() {
  const esp_sleep_wakeup_cause_t wakeCause = esp_sleep_get_wakeup_cause();
  currentMode = wakeCause == ESP_SLEEP_WAKEUP_EXT1 &&
                        digitalRead(Pins::relayTrigger) == HIGH
                    ? MainMode::Firing
                    : MainMode::Standby;
}

void enterDeepSleep() {
  digitalWrite(Pins::gunPower, LOW);
  digitalWrite(Pins::buzzer, LOW);
  digitalWrite(Pins::leftGun, LOW);
  digitalWrite(Pins::rightGun, LOW);

  const uint64_t wakeMask = (1ULL << Pins::relayTrigger) |
                            (1ULL << Pins::switch7) | (1ULL << Pins::switch6) |
                            (1ULL << Pins::switch5) | (1ULL << Pins::switch4) |
                            (1ULL << Pins::switch3) | (1ULL << Pins::switch2) |
                            (1ULL << Pins::switch1);
  esp_sleep_enable_ext1_wakeup(wakeMask, ESP_EXT1_WAKEUP_ANY_HIGH);
  esp_deep_sleep_start();
}