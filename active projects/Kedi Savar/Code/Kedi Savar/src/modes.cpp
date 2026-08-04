#include <Arduino.h>
#include "app_state.h"
#include "modes.h"
#include "persistent_state.h"
#include "pins.h"

namespace {
bool displayBattery = false;
unsigned long calibrationStartedAt = 0;
unsigned long firingStartedAt = 0;
unsigned long pulseStartedAt = 0;
unsigned char firingCycle = 0;
bool leftPulse = false;
constexpr unsigned long calibrationTimeoutMs = 30000;
constexpr unsigned long pulseMs = 250;
constexpr unsigned long pauseMs = 250;

void setGuns(bool left, bool right) {
  digitalWrite(Pins::leftGun, left ? HIGH : LOW);
  digitalWrite(Pins::rightGun, right ? HIGH : LOW);
}

void showHex(unsigned char value) {
  const unsigned char mask = Pins::hexSegmentMap[value & 0x0F];
  for (size_t index = 0; index < 8; ++index)
    digitalWrite(Pins::segmentPins[index], (mask >> index) & 1 ? Pins::LED_ON : Pins::LED_OFF);
}
}

void runStandbyMode() {
  setGuns(false, false);
  digitalWrite(Pins::gunPower, LOW);
  digitalWrite(Pins::statusLeds[0], persistentState.armed ? HIGH : LOW);
}

void runCalibrationMode() {
  setGuns(false, false);
  digitalWrite(Pins::gunPower, HIGH);
  if (calibrationStartedAt == 0) calibrationStartedAt = millis();
  if (digitalRead(Pins::relayTrigger) == LOW ||
      millis() - calibrationStartedAt >= calibrationTimeoutMs) {
    digitalWrite(Pins::buzzer, HIGH);
    delay(100);
    digitalWrite(Pins::buzzer, LOW);
    digitalWrite(Pins::gunPower, LOW);
    calibrationStartedAt = 0;
    currentMode = MainMode::Standby;
  }
}

void runFiringMode() {
  if (!persistentState.armed || (!persistentState.leftGunEnabled && !persistentState.rightGunEnabled)) {
    currentMode = MainMode::Standby;
    return;
  }
  const unsigned long now = millis();
  if (firingStartedAt == 0) {
    firingStartedAt = now;
    pulseStartedAt = now;
    firingCycle = 0;
    leftPulse = persistentState.leftGunEnabled;
  }
  if (digitalRead(Pins::relayTrigger) == LOW || now - firingStartedAt >= firingTimeoutMs ||
      firingCycle >= firingCycles) {
    setGuns(false, false);
    digitalWrite(Pins::gunPower, LOW);
    recordActivation();
    firingStartedAt = 0;
    currentMode = MainMode::Standby;
    return;
  }
  digitalWrite(Pins::gunPower, HIGH);
  const unsigned long phaseMs = now - pulseStartedAt;
  if (phaseMs < pulseMs) {
    setGuns(leftPulse && persistentState.leftGunEnabled,
            !leftPulse && persistentState.rightGunEnabled);
  } else if (phaseMs < pulseMs + pauseMs) {
    setGuns(false, false);
  } else {
    ++firingCycle;
    leftPulse = !leftPulse;
    pulseStartedAt = now;
  }
}

void runDisplayMode() {
  const unsigned long value = displayBattery
                                  ? map(analogRead(Pins::batteryAdc), 0, 4095, 0, 15)
                                  : persistentState.activationCount;
  showHex(static_cast<unsigned char>(value));
}