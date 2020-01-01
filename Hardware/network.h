#ifndef NETWORK_H
#define NETWORK_H

struct Network {
    static void sendData(float values[]) {
        float pm1 = values[0];
        float pm2_5 = values[1];
        float pm10 = values[2];
        float humidity = values[3];
        float temperature = values[4];
        float voc = values[5];
        float carbon_monoxide = values[6];
        sendData(pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide);
    }

    static void sendData(float pm1, float pm2_5, float pm10, float humidity,
                  float temperature, float voc, float carbon_monoxide) {
        Serial.println("Connecting to server");
        BearSSL::WiFiClientSecure client;
        client.setFingerprint(fingerprint);
        if (!client.connect(HOST, 443)) {
            Serial.println("Connection failed!");
            return;
        }
        Serial.println("Connected to server!");

        String url = "/update/?api_key=";
        url += API_KEY;
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

        client.print(String("GET ") + url + " HTTP/1.1\r\n" + "Host: " + HOST +
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
};

#endif