//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import TempestKit

/// One message from the live WebSocket feed.
///
/// The feed sends device readings, not station readings. A Tempest, an Air
/// and a Sky all come through as `DeviceObservation`.
public enum TempestWebSocketEvent: Hashable, Sendable {

    /// The server accepted a request. `id` is the id we sent.
    case acknowledged(id: String)

    /// A new reading from a device.
    case observation(
        deviceID: WeatherStation.Device.ID,
        observation: DeviceObservation
    )

    /// A 3 second wind sample. `speed` is m/s, and `direction` is where the
    /// wind comes from in degrees.
    case rapidWind(
        deviceID: WeatherStation.Device.ID,
        timestamp: Date,
        speed: Double,
        direction: Double
    )

    /// One lightning strike. `distance` is km.
    case lightningStrike(
        deviceID: WeatherStation.Device.ID,
        timestamp: Date,
        distance: Double,
        energy: Double
    )

    /// The rain sensor saw the first drops of a new rain event.
    ///
    /// The WebSocket message has no timestamp, unlike the UDP one. Use the
    /// time the event arrived.
    case rainStart(deviceID: WeatherStation.Device.ID)

    /// A lightning strike in the box you asked the feed to watch.
    case geoStrike(
        time: Date,
        latitude: Double,
        longitude: Double,
        magnitude: Int?,
        strikeType: StrikeType?
    )
}
