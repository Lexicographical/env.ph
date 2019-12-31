#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <DHT.h>
#include <SoftwareSerial.h>
#include <EEPROM.h>
#include <Wire.h>
#include <Seeed_HM330X.h>
#include <LowPower.h>
#include "constants.h"
#include "utility.h"
#include "network.h"
#include "device.h"

// TODO: convert ESP8266 code into AT commands for ESP32
void setup() {
    Serial.begin(115200);
    Serial.setDebugOutput(true);
    delay(10);

    Serial.println();
    Serial.println();
    Serial.print("Connecting to network: ");
    Serial.println(Constants::ssid);

    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("Connected!");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}

void loop() {
    if (!connected) {
        return;
    }
    // Check for stored values in EEPROM
    if (EEPROM.read(0)) {
        Serial.println("Loading stored values from EEPROM");
        Device::loadEEPROM();
    } else {
        Serial.println("No values found in EEPROM");
        Device::readSensors();
        Network::sendData();
        Device::sleep10Mins();
    }

    float pm1 = 6;
    float pm2_5 = 8;
    float pm10 = 12;
    float humidity = 95;
    float temperature = 26;
    float voc = 1;
    float carbon_monoxide = 4;
    sendData(pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide);
    delay(5000);
}