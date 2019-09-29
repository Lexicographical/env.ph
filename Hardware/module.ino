#include <ESP8266WiFi.h>
#include <FS.h>
#include <WiFiClientSecure.h>

const char* ssid = "";                     // insert your WiFi SSID here
const char* password = "";                 // insert your WiFi password here
const char* host = "api.beta.amihan.xyz";  // url of the remote API
const char* api_key = "";  // insert your device's API key here. View it on the
                           // website or ask one of the administrators
// SHA1 fingerprint of the website
const char* fingerprint PROGMEM =
    "ED 57 87 4A 1E 44 04 CA 2F E2 8F 68 A0 3C 28 53 44 EA 91 F9";

void setup() {
    Serial.begin(115200);
    Serial.setDebugOutput(true);
    delay(10);

    Serial.println();
    Serial.println();
    Serial.print("Connecting to network: ");
    Serial.println(ssid);

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
    // replace the hardcoded values with the values retrieved from the sensors
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

void sendData(float pm1, float pm2_5, float pm10, float humidity,
              float temperature, float voc, float carbon_monoxide) {
    Serial.println("Connecting to server");
    BearSSL::WiFiClientSecure client;
    client.setFingerprint(fingerprint);
    if (!client.connect(host, 443)) {
        Serial.println("Connection failed!");
        return;
    }
    Serial.println("Connected to server!");

    String url = "/update/?api_key=";
    url += api_key;
    url += "&pm1=";
    url += pm1;
    url += "&pm2_5=";
    url += pm2_5;
    url += "&pm10=";
    url += pm10;
    url += "&humidity=";
    url += humidity;
    url += "&temperature=";
    url += temperature;
    url += "&voc=";
    url += voc;
    url += "&carbon_monoxide=";
    url += carbon_monoxide;

    client.print(String("GET ") + url + " HTTP/1.1\r\n" + "Host: " + host +
                 "\r\n" + "Connection: close\r\n\r\n");

    Serial.println("Server Response:");
    while (client.connected() || client.available()) {
        if (client.available()) {
            String line = client.readStringUntil('\n');
            Serial.println(line);
        }
    }

    Serial.println();
    Serial.println("Closing connection");
}
