/*

Sonometer

Copyright (C) 2017 Xose Pérez <xose dot perez at gmail dot com>

Requires FastLED library (https://github.com/FastLED/FastLED)

---------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#define SERIAL_BAUDRATE         115200

#define POTENTIOMETER_PIN       A1

#define LED_PIN                 10
#define LED_COUNT               24

#define MICROPHONE_PIN          A0
#define ADC_BITS                10
#define ADC_COUNTS              (1 << ADC_BITS)

#define NOISE_READING_WINDOW    20
#define NOISE_BUFFER_SIZE       20
#define NOISE_READING_DELAY     100
#define NOISE_MAX               1024

// -----------------------------------------------------------------------------

#include "FastLED.h"

// -----------------------------------------------------------------------------

CRGB leds[LED_COUNT];
unsigned int noise_buffer[NOISE_BUFFER_SIZE] = {0};
unsigned int noise_buffer_pointer = 0;
unsigned int noise_buffer_sum = 0;

// -----------------------------------------------------------------------------

CRGB getColor(unsigned int percent) {
    unsigned char red = map(percent, 0, 100, 0, 255);
    unsigned char green = map(percent, 0, 100, 255, 0);
    return CRGB(red, green, 0);
}

void showValue(unsigned int percent) {
    unsigned int num = LED_COUNT * percent / 100;
    for (unsigned int i=0; i<num; i++) {
        leds[i] = getColor(i * 100 / LED_COUNT);
    }
    for (unsigned int i=num; i<LED_COUNT; i++) {
        leds[i] = 0;
    }
    FastLED.show();
}

void noiseLoop() {

    static unsigned long last_reading = 0;

    unsigned int sample;
    unsigned int min = ADC_COUNTS;
    unsigned int max = 0;

    // Check MIC every NOISE_READING_DELAY
    if (millis() - last_reading < NOISE_READING_DELAY) return;
    last_reading = millis();

    // Get potentiomenter
    unsigned int max_noise = map(analogRead(POTENTIOMETER_PIN), 0, ADC_COUNTS, 0, NOISE_MAX);
    if (max_noise == 0) {
        FastLED.clear();
        FastLED.show();
        return;
    }

    while (millis() - last_reading < NOISE_READING_WINDOW) {
        sample = analogRead(MICROPHONE_PIN);
        if (sample < min) min = sample;
        if (sample > max) max = sample;
    }

    unsigned int peak = map(max - min, 0, ADC_COUNTS, 0, 100);

    noise_buffer_sum = noise_buffer_sum + peak - noise_buffer[noise_buffer_pointer];
    noise_buffer[noise_buffer_pointer] = peak;
    noise_buffer_pointer = (noise_buffer_pointer + 1) % NOISE_BUFFER_SIZE;

    showValue(constrain(map(noise_buffer_sum, 0, max_noise, 0, 100), 0, 100));

}

void setup() {
    Serial.begin(SERIAL_BAUDRATE);
    FastLED.addLeds<NEOPIXEL, LED_PIN>(leds, LED_COUNT);
    pinMode(MICROPHONE_PIN, INPUT);
    pinMode(POTENTIOMETER_PIN, INPUT);
}

void loop() {
    noiseLoop();
}
