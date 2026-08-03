#include <Arduino.h>
#include "app_state.h"
#include "buttons.h"
#include "persistent_state.h"
#include "pins.h"

namespace {
constexpr unsigned long debounceMs = 35;
constexpr unsigned long longPressMs = 800;
const unsigned char buttonPins[] = {Pins::switch1, Pins::switch2, Pins::switch3,
                                    Pins::displayButton, Pins::leftGunButton,
                                    Pins::rightGunButton, Pins::calibrationButton};
constexpr size_t buttonCount = sizeof(buttonPins) / sizeof(buttonPins[0]);
bool previousState[buttonCount] = {};
unsigned long pressedAt[buttonCount] = {};
unsigned long changedAt[buttonCount] = {};
}

void handleButtons() {
  const unsigned long now = millis();
  for (size_t index = 0; index < buttonCount; ++index) {
    const bool pressed = digitalRead(buttonPins[index]) == HIGH;
    if (pressed != previousState[index] && now - changedAt[index] >= debounceMs) {
      previousState[index] = pressed;
      changedAt[index] = now;
      if (pressed) {
        pressedAt[index] = now;
        lastActivityMs = now;
        continue;
      }

      const bool longPress = now - pressedAt[index] >= longPressMs;
      if (buttonPins[index] == Pins::calibrationButton && !longPress) {
        currentMode = MainMode::Calibration;
      } else if (buttonPins[index] == Pins::leftGunButton && !longPress) {
        persistentState.leftGunEnabled = !persistentState.leftGunEnabled;
      } else if (buttonPins[index] == Pins::rightGunButton && !longPress) {
        persistentState.rightGunEnabled = !persistentState.rightGunEnabled;
      } else if (buttonPins[index] == Pins::displayButton && !longPress) {
        currentMode = MainMode::Display;
      } else if (buttonPins[index] == Pins::switch3 && longPress) {
        persistentState.armed = !persistentState.armed;
      }
      lastActivityMs = now;
    }
  }
}