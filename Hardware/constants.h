#ifndef CONSTANTS_H
#define CONSTANTS_H

#define DEBUG true; // set to true to enable debug mode

const char* WLAN_SSID = "";                     // insert your WiFi SSID here
const char* WLAN_PASS = "";                 // insert your WiFi password here
const char* HOST = "api.beta.amihan.xyz";  // url of the remote API
const char* API_KEY = "";  // insert your device's API key here

// Calibration factors. Change these as necessary.
const float R0_MQ135 = 4481.01;
const float R0_MQ7 = 7990.24;

// modify these according to your configuration
#define PIN_RX 2
#define PIN_TX 3
#define PIN_MQ7 A3 
#define PIN_MQ135 A2
#define PIN_DHT 4
#define PIN_SDA A4
#define PIN_SCL A5
#define TYPE_DHT DHT11
#define HM3301 0x40
#define CMD 0x88

// Do not modify these
// SHA1 fingerprint of the website certificate
const char* fingerprint PROGMEM =
    "ED 57 87 4A 1E 44 04 CA 2F E2 8F 68 A0 3C 28 53 44 EA 91 F9";
const char* labels[7] = {"pm1", "pm2_5", "pm10", "humidity", "temperature", "voc", "carbon_monoxide"};

#endif