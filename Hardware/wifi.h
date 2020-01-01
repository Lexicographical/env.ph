#ifndef WIFI_H
#define WIFI_H

class WifiModule {
private:
    SoftwareSerial esp (PIN_RX, PIN_TX);

    void printResponse() {
        while (this->esp.available()) {
            Serial.println(this->esp.readStringUntil("\n"));
        }
    }

    void sendAT(string command) {
        this->esp.println(command);
        delay(1000);
        printResponse();
    }

// TODO: implement https through AT commands
public:
    WifiModule() {
        sendAT("AT+CIPMUX=1");
        sendAT("AT+CWMODE=1");
        sendAT("AT+CWJAP=\"" + WLAN_SSID + "\", \"" + WLAN_PASS + "\"");
    }

    void connect() {
        sendAT("AT+CIPSTART=1,\"TCP\",\"" + HOST + "\",443");
    }
    
};

#endif