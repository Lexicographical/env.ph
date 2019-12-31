#ifndef UTILITY_H
#define UTILITY_H

float pm1 = 0;
float pm2_5 = 0;
float pm10 = 0;
float humidity = 0;
float temperature = 0;
float voc = 0;
float carbon_monoxide = 0;

int timeout_count = 0;
unsigned char data[30];
unsigned short value;
unsigned short values[7];

bool connected = true;
bool emp = false;

int address = 0;

// MQ-135 Gas Sensor
float RS_gas_mq135 = 0;
float ratio_mq135 = 0;
float voltage_mq135 = 0;

// MQ-7 Gas Sensor
float RS_gas_mq7 = 0;
float ratio_mq7 = 0;
float voltage_mq7 = 0;

// VOC sensor
float ppm_voc = 0;
float ppm_carbon_monoxide = 0;

int con_counter = 0;

// Utility debug functions
void debug(const char* val) {
    if (DEBUG) Serial.print(val);
}

void debug(byte val) {
    if (DEBUG) Serial.print(val);
}

void debug(int val) {
    if (DEBUG) Serial.print(val);
}

void debug(float val) {
    if (DEBUG) Serial.print(val);
}

void debug() {
    if (DEBUG) Serial.print();
}

void debugln(const char* val) {
    if (DEBUG) Serial.println(val);
}

void debugln(byte val) {
    if (DEBUG) Serial.println(val);
}

void debugln(int val) {
    if (DEBUG) Serial.println(val);
}

void debugln(float val) {
    if (DEBUG) Serial.println(val);
}

void debugln() {
    if (DEBUG) Serial.println();
}

#endif