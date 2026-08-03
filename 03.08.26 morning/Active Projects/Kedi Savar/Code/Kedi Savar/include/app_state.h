#pragma once

enum class MainMode {
  Standby,
  Calibration,
  Firing,
  Display,
};

enum class ButtonEvent {
  None,
  ShortPress,
  LongPress,
};

extern MainMode currentMode;
extern unsigned long lastActivityMs;