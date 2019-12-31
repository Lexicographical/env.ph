#ifndef DEVICE_H
#define DEVICE_H

#ifndef CONSTANTS_H
#include "constants.h"
#endif

#ifndef UTILITY_H
#include "utility.h"
#endif

struct Device {
    static DHT dht(PIN_DHT, TYPE_DHT);

    // power down the device for 75 8-second cycles (10 minutes)
    static void sleep10Mins() {
        for (int i = 0; i < 15 * 5; i++) {
            LowPower.powerDown(SLEEP_8S, ADC_OFF, BOD_OFF);
        }
    }

    static void loadEEPROM() {
        for (int i = 0; i < EEPROM.length(); i++) {
            byte value = EEPROM.read(i);
            if (value != 0) {
                /*
                Cached values for PM1, PM2_5, PM10, humidity,
                temperature, voc, and carbon monoxide
                */
                float values[7];
                debugln("EEPROM Values");
                for (int j = 0; j < 7; j++) {
                    byte val = EEPROM.read(i + j);
                    values[j] = float(val) + (j > 4 ? 255 : 0);
                    debug(labels[j]);
                    debug(": ");
                    debugln(val);
                }
                // Upload the data to the server
                Network::sendData(values);
                delay(20000);
                i += 6;
            }
        }
        // Clear EEPROM after reading
        Device::clearEEPROM();
    }

    static float getPPMFromMQ(float value, float R0) {
        float voltage = value / 1024 * 5.0;
        float RS = (5.0 - voltage) / voltage;
        float ratio = RS / R0;
        float x = 1538.46 * ratio;
        float ppm = pow(x, -1.709);
        return round(ppm);
    }

    static void readSensors() {
        Serial.println("Reading from sensors");

        // Reading humidity and temperature from DHT
        humidity = dht.readHumidity();
        Serial.print("Humidity: ");
        Serial.print(humidity);
        Serial.println("%");

        temperature = dht.readTemperature();
        Serial.print("Temperature: ");
        Serial.print(temperature);
        Serial.println(" \u2103C");

        // Reading carbon monoxide levls from MQ7
        carbon_monoxide = analogRead(PIN_MQ7);
        ppm_carbon_monoxide = getPPMFromMQ(carbon_monoxide, R0_MQ7);
        Serial.print("Carbon Monoxide: ");
        Serial.print(ppm_carbon_monoxide);
        Serial.println(" PPM");

        // Reading voc levels from MQ135
        voc = analogRead(PIN_MQ135);
        ppm_voc = Device::getPPMFromMQ(voc, PIN_MQ135);
        Serial.print("VOC: ");
        Serial.print(ppm_voc);
        Serial.println(" PPM");

        // Dust sensors
        Wire.beginTransmission(HM3301);
        Wire.write(CMD);
        Wire.endTransmission();
        Wire.requestFrom(HM3301, 29);

        while (Wire.available() != 29) {
            timeout_count++;
            if (timeout_count > 10)
            delay(1);
        }
        for (int i = 0; i < 28; i++) {
            data[i] = Wire.read();
        }

    }
};

#endif