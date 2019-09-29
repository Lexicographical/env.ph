# Amihan

This directory contains the resources and source code for the amihan server-side web application. Furthermore, it also contains code for dummy data generation for testing.

*The following section contains TEMPORARY documentation for the API.*

# API Documentation

The Amihan API allows users and devices to communicate to a central server
containing sensor data. Users can retreive sensor data from the server, while
devices can update the server with new values.

*All parameters marked in **bold** are required.*

## Queries

Sensor data can be queried either in its entirety or narrowed through specified
filters.

#### Listing Sensors

```GET https://api.beta.amihan.xyz/query/list```


Output:

| Value       | Type        | Description |
| ----------- | ----------- | ----------- |
| src_id      | integer     | Positive integer representing the assigned index of the sensor.|
| location_name | string    | Physical address of the sensor |
| latitude    | double      | Latitude of physical address |
| longitude   | double      | Longitude of physical address |

#### Querying Sensors

```GET https://api.beta.amihan.xyz/query/sensor```

This queries the sensor at the specific sensor ID given.

Parameters:

| Parameter   | Type        | Description |
| ----------- | ----------- | ----------- |
| **src_id**  | integer     | Positive integer representing the assigned index of the sensor.|

Output (JSON):

```json
{
    "location_name": "1010 Rizal Ave, Metro Manila",
    "latitude": 14.1010,
    "longitude": 141.0101,
    "creation_time": "2019-09-30 00:"
}
```

| Value       | Type        | Description |
| ----------- | ----------- | ----------- |
| location_name | string    | Physical address of the sensor |
| latitude    | double      | Latitude of physical address |
| longitude   | double      | Longitude of physical address |
| creation_time | timestamp | Timestamp of registration time of device |

##### Specific Data Type

```GET https://api.beta.amihan.xyz/query/sensor/{data_type}```

Retrieves all PM<sub>1.0</sub> data for a specified sensor ID and data type.

Replace ```{data_type}``` with the appropriate type from the following list:

| Name        | ```data_type```   |
| ----------- | ----------- |
| PM<sub>1.0</sub> | ```pm1``` |
| PM<sub>2.5</sub> | ```pm25``` |
| PM<sub>10</sub> | ```pm10``` |
| Humidity | ```humidity``` |
| Temperature | ```temperature``` |
| Volatile Organic Compounds | ```voc``` |
| Carbon Monoxide | ```carbonMonoxide``` |

Parameters:

| Parameter   | Type        | Description |
| ----------- | ----------- | ----------- |
| **src_id**  | integer     | Positive integer representing the assigned index of the sensor.|

Output:

| Value       | Type        | Description |
| ----------- | ----------- | ----------- |
| entry_time  | timestamp   | Timestamp of entry time of data point. |
| *{data_type}* | double  | Data point for specific data type. |

## Update (Sensor)

WIP