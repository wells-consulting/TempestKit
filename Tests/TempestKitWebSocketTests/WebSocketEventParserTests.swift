//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

import TempestKit

@testable import TempestKitWebSocket

struct WebSocketEventParserTests {

    private let parser = WebSocketEventParser()

    @Test("An ack keeps its request id")
    func ack() throws {
        let events = parser.parse(#"{"type":"ack","id":"2098388936"}"#)
        let event = try #require(events.first)
        #expect(event == .acknowledged(id: "2098388936"))
    }

    @Test("An ack with a number id works too")
    func numericAck() throws {
        let events = parser.parse(#"{"type":"ack","id":12345}"#)
        #expect(events == [.acknowledged(id: "12345")])
    }

    @Test("A Tempest reading maps its row")
    func tempest() throws {
        let json = #"{"type":"obs_st","device_id":62009,"obs":[[1603481377,0,0.09,0.54,33,6,1014.8,28.8,71,16639,1.83,139,0,0,0,0,2.42,1,0.07615,null,null,0]]}"#
        let events = parser.parse(json)
        let event = try #require(events.first)

        guard case .observation(let deviceID, let observation) = event else {
            Issue.record("Expected an observation, got \(event)")
            return
        }
        #expect(deviceID == 62009)
        #expect(observation.deviceType == .tempest)
        #expect(observation.airTemperature == 28.8)
        #expect(observation.batteryVoltage == 2.42)
        #expect(observation.windSampleInterval == 6)
        #expect(observation.localDayPrecipitation == 0.07615)
        #expect(observation.precipitationAnalysis == .noAnalysis)
    }

    @Test("An Air reading maps its row")
    func air() throws {
        let json = #"{"type":"obs_air","device_id":1110,"obs":[[1493164835,835.0,10.0,45,0,0,3.46,1]]}"#
        let events = parser.parse(json)
        let event = try #require(events.first)

        guard case .observation(let deviceID, let observation) = event else {
            Issue.record("Expected an observation, got \(event)")
            return
        }
        #expect(deviceID == 1110)
        #expect(observation.deviceType == .air)
        #expect(observation.airTemperature == 10)
        #expect(observation.stationPressure == 835)
    }

    @Test("A Sky reading maps its row")
    func sky() throws {
        let json = #"{"type":"obs_sky","device_id":1110,"obs":[[1493321340,9000,10,0.0,2.6,4.6,7.4,187,3.12,1,130,1.034,0,3,0.0,1.011,1]]}"#
        let events = parser.parse(json)
        let event = try #require(events.first)

        guard case .observation(let deviceID, let observation) = event else {
            Issue.record("Expected an observation, got \(event)")
            return
        }
        #expect(deviceID == 1110)
        #expect(observation.deviceType == .sky)
        #expect(observation.windAverage == 4.6)
        #expect(observation.localDayPrecipitation == 1.034)
        #expect(observation.precipitationAnalysis == .rainCheckShown)
    }

    @Test("rapid_wind maps its row")
    func rapidWind() throws {
        let json = #"{"type":"rapid_wind","device_id":1110,"ob":[1493322445,2.3,128]}"#
        let events = parser.parse(json)
        let event = try #require(events.first)

        guard case .rapidWind(let deviceID, let timestamp, let speed, let direction) = event else {
            Issue.record("Expected rapid wind, got \(event)")
            return
        }
        #expect(deviceID == 1110)
        #expect(timestamp == Date(timeIntervalSince1970: 1_493_322_445))
        #expect(speed == 2.3)
        #expect(direction == 128)
    }

    @Test("evt_strike maps its row")
    func strike() throws {
        let json = #"{"type":"evt_strike","device_id":1110,"evt":[1493322445,27,3848]}"#
        let events = parser.parse(json)
        let event = try #require(events.first)

        guard case .lightningStrike(let deviceID, let timestamp, let distance, let energy) = event else {
            Issue.record("Expected a strike, got \(event)")
            return
        }
        #expect(deviceID == 1110)
        #expect(timestamp == Date(timeIntervalSince1970: 1_493_322_445))
        #expect(distance == 27)
        #expect(energy == 3848)
    }

    @Test("evt_precip has no timestamp")
    func rainStart() throws {
        let json = #"{"type":"evt_precip","device_id":1110}"#
        let events = parser.parse(json)
        #expect(events == [.rainStart(deviceID: 1110)])
    }

    @Test("A geo strike maps its row")
    func geoStrike() throws {
        let json = #"{"type":"geo_strike","time":1656008011,"lat":38.9981994,"lon":99.3110134,"mag":289,"strike_type":"cg"}"#
        let events = parser.parse(json)
        let event = try #require(events.first)

        guard case .geoStrike(let time, let latitude, let longitude, let magnitude, let strikeType) = event else {
            Issue.record("Expected a geo strike, got \(event)")
            return
        }
        #expect(time == Date(timeIntervalSince1970: 1_656_008_011))
        #expect(latitude == 38.9981994)
        #expect(longitude == 99.3110134)
        #expect(magnitude == 289)
        #expect(strikeType == .cloudToGround)
    }

    @Test("A reading without a device is ignored")
    func missingDevice() {
        let json = #"{"type":"obs_st","obs":[[1603481377,0,0.09,0.54,33,6,1014.8,28.8,71,16639,1.83,139,0,0,0,0,2.42,1]]}"#
        #expect(parser.parse(json).isEmpty)
    }

    @Test("A message we don't know is ignored")
    func unknownType() {
        let json = #"{"type":"brand_new","time":1656008011}"#
        #expect(parser.parse(json).isEmpty)
    }

    @Test("A message that isn't JSON is ignored")
    func garbage() {
        #expect(parser.parse("not json").isEmpty)
    }
}
