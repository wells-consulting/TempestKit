# ``TempestKit``

A Swift package for the WeatherFlow Tempest weather station: the REST API, the WebSocket feed and the local broadcasts.

> Important: TempestKit isn't made by, endorsed by or supported by WeatherFlow. "Tempest" is their product name, used here so you know what the package talks to. The API docs are at <https://apidocs.tempestwx.com>.

## Overview

`TempestClient` covers the Tempest Home API: your stations, their readings over time, the latest conditions, daily statistics and the forecast. Every call takes a personal access token or an OAuth token.

The package has two other products. `TempestKitUDP` reads the hub's broadcasts on the local network and needs no token. `TempestKitWebSocket` holds one connection open and pushes device readings as they happen.

The numbers are metric unless you ask the forecast for something else. The station owner's choice in the Tempest app is a display setting; it doesn't change what the API returns.

## Topics

### Guides

- <doc:getting-started>
- <doc:models>
- <doc:tokens>
- <doc:ranges-and-buckets>
- <doc:forecast-and-units>
- <doc:errors>
- <doc:reading-live-data>
- <doc:api-coverage>
- <doc:field-notes>
- <doc:sources>

### Essentials

- ``TempestClient``
- ``TempestError``

### Stations

- ``WeatherStation``
- ``WeatherStation/Device``
- ``WeatherStation/Item``
- ``WeatherStation/Capability``
- ``StationSet``

### Observations

- ``StationObservation``
- ``StationObservations``
- ``ObservationBucket``
- ``DeviceObservation``
- ``DeviceObservation/RowType``
- ``DeviceObservations``
- ``DeviceObservationRange``
- ``DeviceSummary``

### Conditions

- ``StationConditions``
- ``StationConditions/Indoor``
- ``CalculatedValues``
- ``DisplayUnits``

### Forecast

- ``TempestForecast``
- ``TempestForecast/CurrentConditions``
- ``TempestForecast/Hour``
- ``TempestForecast/Day``
- ``TempestForecast/Station``
- ``TempestForecast/Icon``
- ``CompassPoint``
- ``Units``

### Statistics

- ``StationStatistics``
- ``StationStatistics/Day``
- ``StationStatistics/Times``
- ``PressureTrend``

### Readings and status

- ``PrecipitationType``
- ``PrecipitationAnalysis``
- ``ResponseStatus``
- ``SensorStatus``
- ``ResetFlags``
- ``DeviceStatus``
- ``HubStatus``
- ``RadioState``
- ``RadioStats``
