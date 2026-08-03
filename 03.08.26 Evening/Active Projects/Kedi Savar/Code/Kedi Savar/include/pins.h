#pragma once

#include <Arduino.h>

namespace Pins {
constexpr unsigned char relayTrigger = 1;
constexpr unsigned char gunPower = 20;
constexpr unsigned char buzzer = 37;
constexpr unsigned char leftGun = 36;
constexpr unsigned char rightGun = 35;
constexpr unsigned char batteryAdc = 19;

constexpr unsigned char switch7 = 4;
constexpr unsigned char switch6 = 5;
constexpr unsigned char switch5 = 6;
constexpr unsigned char switch4 = 7;
constexpr unsigned char switch3 = 15;
constexpr unsigned char switch2 = 16;
constexpr unsigned char switch1 = 17;

constexpr unsigned char calibrationButton = switch7;
constexpr unsigned char leftGunButton = switch6;
constexpr unsigned char rightGunButton = switch5;
constexpr unsigned char displayButton = switch4;

constexpr unsigned char statusLeds[] = {18, 8, 3, 46};
constexpr unsigned char segmentPins[] = {9, 10, 11, 12, 13, 48, 47, 21};

constexpr unsigned char LED_ON = HIGH;
constexpr unsigned char LED_OFF = LOW;

constexpr unsigned char hexSegmentMap[16] = {
	0b00111111,
	0b00000110,
	0b01011011,
	0b01001111,
	0b01100110,
	0b01101101,
	0b01111101,
	0b00000111,
	0b01111111,
	0b01101111,
	0b01110111,
	0b01111100,
	0b00111001,
	0b01011110,
	0b01111001,
	0b01110001,
};
}

constexpr unsigned long standbyTimeoutMs = 5UL * 60UL * 1000UL;
constexpr unsigned long firingTimeoutMs = 10UL * 1000UL;
constexpr unsigned char firingCycles = 5;
