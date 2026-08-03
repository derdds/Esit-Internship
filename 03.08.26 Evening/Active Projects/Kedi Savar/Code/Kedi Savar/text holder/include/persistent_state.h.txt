#pragma once

#include <Arduino.h>

constexpr unsigned char persistentHistoryHours = 24;

struct PersistentState {
  bool armed;
  bool leftGunEnabled;
  bool rightGunEnabled;
  uint32_t activationCount;
  uint16_t hourlyActivations[persistentHistoryHours];
};

extern PersistentState persistentState;

void restorePersistentState();
void savePersistentState();
void recordActivation();
