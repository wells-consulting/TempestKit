//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct StationsMappingTests {

    // A real /stations response. The token in it has been rotated, so it
    // doesn't work anymore.
    private static let fixture = """
        {
            "status": {"status_code": 0, "status_message": "SUCCESS"},
            "stations": [{
                "station_id": 100001,
                "name": "Test Station",
                "latitude": 37.77493,
                "longitude": -122.41942,
                "timezone": "America/Los_Angeles",
                "created_epoch": 1791481417,
                "devices": [
                    {"device_id": 200001, "device_type": "HB", "serial_number": "HB-00012345", "firmware_revision": 343},
                    {"device_id": 200002, "device_type": "ST", "serial_number": "ST-00054321", "firmware_revision": 193}
                ]
            }]
        }
        """

    @Test("A station decodes with its devices and time zone")
    func stationMapping() throws {
        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data(Self.fixture.utf8))
        #expect(response.stations.count == 1)

        let station = WeatherStation(dto: try #require(response.stations.first))
        #expect(station.id == 100001)
        #expect(station.name == "Test Station")
        #expect(station.latitude == 37.77493)
        #expect(station.longitude == -122.41942)
        #expect(station.timeZone?.identifier == "America/Los_Angeles")
        #expect(station.createdAt == Date(timeIntervalSince1970: 1_791_481_417))
        #expect(station.devices.map(\.deviceType) == [.hub, .tempest])
        #expect(station.devices.map(\.firmwareRevision) == ["343", "193"])
    }

    @Test("Firmware revision works as a string or a number")
    func firmwareRevisionAsText() throws {
        let fixture = """
            {"stations": [{
                "station_id": 1, "latitude": 0, "longitude": 0,
                "devices": [{"device_id": 2, "device_type": "ST", "firmware_revision": "193"}]
            }]}
            """

        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data(fixture.utf8))
        let station = WeatherStation(dto: try #require(response.stations.first))
        #expect(station.devices.first?.firmwareRevision == "193")
    }

    @Test("The API's device codes map to the right kind of hardware")
    func deviceTypeCodes() {
        #expect(WeatherStation.DeviceType(code: "ST") == .tempest)
        #expect(WeatherStation.DeviceType(code: "HB") == .hub)
        #expect(WeatherStation.DeviceType(code: "AR") == .air)
        #expect(WeatherStation.DeviceType(code: "SK") == .sky)
    }

    @Test("Unknown hardware becomes .other")
    func unknownDeviceType() {
        #expect(WeatherStation.DeviceType(code: "ST2") == .other)
        #expect(WeatherStation.DeviceType(code: nil) == .other)
        #expect(WeatherStation.DeviceType(code: "st") == .tempest)
        #expect(WeatherStation.DeviceType(code: "ar") == .air)
        #expect(WeatherStation.DeviceType(code: "sk") == .sky)
    }

    @Test("A station carries its metadata, devices and items")
    func metadata() throws {
        let fixture = """
            {"stations": [{
                "location_id": 12799,
                "station_id": 12799,
                "name": "Home",
                "public_name": "San Francisco",
                "latitude": 37.77493,
                "longitude": -122.41942,
                "timezone": "America/Los_Angeles",
                "timezone_offset_minutes": -480,
                "station_meta": {"share_with_wf": true, "share_with_wu": false, "elevation": 150},
                "last_modified_epoch": 1791481500,
                "created_epoch": 1791481417,
                "capabilities": [
                    {"capability": "air_temperature_humidity", "device_id": 2, "environment": "outdoor"},
                    {"capability": "rain", "device_id": 2, "environment": "outdoor", "show_precip_final": true}
                ],
                "state": 1,
                "devices": [
                    {"device_id": 1, "serial_number": "HB-00012345", "device_type": "HB", "firmware_revision": "343", "hardware_revision": "1"},
                    {"device_id": 2, "serial_number": "AR-00004049", "device_type": "AR", "firmware_revision": 17, "hardware_revision": 3, "notes": "Pool", "device_meta": {"agl": 2.2, "name": "Pool Air", "environment": "outdoor", "wifi_network_name": "Home"}, "device_settings": {"show_precip_final": true}}
                ],
                "station_items": [
                    {"location_item_id": 1, "station_item_id": 2, "station_id": 12799, "location_id": 12799, "device_id": 2, "item": "air_temperature_humidity", "sort": 1},
                    {"location_item_id": 3, "station_item_id": 4, "item": null}
                ],
                "is_local_mode": false
            }]}
            """

        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data(fixture.utf8))
        let station = WeatherStation(dto: try #require(response.stations.first))

        #expect(station.locationID == 12799)
        #expect(station.publicName == "San Francisco")
        #expect(station.timezoneOffsetMinutes == -480)
        #expect(station.elevation == 150)
        #expect(station.sharesWithWeatherFlow == true)
        #expect(station.sharesWithWeatherUnderground == false)
        #expect(station.isLocalMode == false)
        #expect(station.state == 1)
        #expect(station.capabilities.count == 2)
        #expect(station.capabilities.first?.name == "air_temperature_humidity")
        #expect(station.capabilities.first?.deviceID == 2)
        #expect(station.capabilities.first?.environment == .outdoor)
        #expect(station.capabilities.last?.showsPrecipitationFinal == true)
        #expect(station.lastModified == Date(timeIntervalSince1970: 1_791_481_500))
        #expect(station.hub?.serialNumber == "HB-00012345")

        let air = try #require(station.devices.last)
        #expect(air.deviceType == .air)
        #expect(air.firmwareRevision == "17")
        #expect(air.hardwareRevision == "3")
        #expect(air.notes == "Pool")
        #expect(air.meta?.heightAboveGround == 2.2)
        #expect(air.meta?.name == "Pool Air")
        #expect(air.meta?.environment == .outdoor)
        #expect(air.meta?.wifiNetworkName == "Home")
        #expect(air.settings?.showsPrecipitationFinal == true)

        #expect(station.items.count == 1)
        let item = try #require(station.items.first)
        #expect(item.name == "air_temperature_humidity")
        #expect(item.deviceID == 2)
        #expect(item.sort == 1)
    }

    @Test("A station without coordinates still decodes")
    func nullCoordinates() throws {
        let fixture = """
            {"stations": [{"station_id": 1, "latitude": null, "longitude": null}]}
            """

        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data(fixture.utf8))
        let station = WeatherStation(dto: try #require(response.stations.first))
        #expect(station.latitude == nil)
        #expect(station.longitude == nil)
    }

    @Test("The swagger file's locations key works too")
    func locationsKey() throws {
        let fixture = """
            {"locations": [{"station_id": 9, "latitude": 1, "longitude": 2}]}
            """

        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data(fixture.utf8))
        #expect(response.stations.first?.stationID == 9)
    }

    @Test("An unknown device environment becomes .other")
    func unknownEnvironment() {
        #expect(WeatherStation.Device.Environment(code: "garage") == .other)
        #expect(WeatherStation.Device.Environment(code: nil) == .other)
        #expect(WeatherStation.Device.Environment(code: "Indoor") == .indoor)
    }

    @Test("A station without a name still decodes")
    func namelessStation() throws {
        let fixture = """
            {"stations": [{"station_id": 7, "latitude": 1, "longitude": 2}]}
            """

        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data(fixture.utf8))
        let station = WeatherStation(dto: try #require(response.stations.first))
        #expect(station.name == "Station 7")
        #expect(station.devices.isEmpty)
        #expect(station.hub == nil)
        #expect(station.timeZone == nil)
    }

    @Test("No stations in the response means an empty list")
    func emptyPayload() throws {
        let response = try JSONDecoder().decode(StationsResponseDTO.self, from: Data("{}".utf8))
        #expect(response.stations.isEmpty)
    }
}
