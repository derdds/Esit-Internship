#include <Arduino.h>
#include "app_state.h"
#include "buttons.h"
#include "hardware.h"
#include "modes.h"
#include "persistent_state.h"
#include "pins.h"

MainMode currentMode = MainMode::Standby;
unsigned long lastActivityMs = 0;

void setup() {
  initializeHardware();
  restorePersistentState();
  handleWakeReason();

  // Run the hardware test only when the boot test buttons are held.
  const bool runHardwareTest = digitalRead(Pins::calibrationButton) == HIGH &&
                               digitalRead(Pins::displayButton) == HIGH;
  if (runHardwareTest) {
    testHardware();
  }

  lastActivityMs = millis();
}

void loop() {
  handleButtons();

  switch (currentMode) {
    case MainMode::Standby:
      runStandbyMode();
      break;
    case MainMode::Calibration:
      runCalibrationMode();
      break;
    case MainMode::Firing:
      runFiringMode();
      break;
    case MainMode::Display:
      runDisplayMode();
      break;
  }

  if (millis() - lastActivityMs >= standbyTimeoutMs) {
    savePersistentState();
    enterDeepSleep();
  }
}
