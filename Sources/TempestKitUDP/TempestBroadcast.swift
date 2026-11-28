//
// TempestKitUDP
// Copyright 2026 Wells Consulting. MIT licensed.
//

#if canImport(Network)
import Foundation
import TempestKit

/// One message the station's hub broadcast on your local network.
///
/// Values are metric, the same as the REST API: m/s, degrees and km. Every
/// case carries the serial number of the device that sent it, so a station
/// with an Air and a Sky is readable.
public enum TempestBroadcast: Hashable, Sendable {

    /// The once-a-minute reading from a Tempest.
    ///
    /// This is the same type the REST API returns, so it can replace one on
    /// screen. The broadcast doesn't send sea level pressure, so that's nil.
    case observation(serialNumber: String, observation: StationObservation)

    /// The once-a-minute reading from an Air: pressure, temperature and
    /// humidity.
    case airObservation(serialNumber: String, observation: DeviceObservation)

    /// The once-a-minute reading from a Sky: wind, light and rain.
    case skyObservation(serialNumber: String, observation: DeviceObservation)

    /// A 3 second wind sample. `speed` is m/s, and `direction` is where the
    /// wind comes from in degrees.
    case rapidWind(
        serialNumber: String,
        hubSerialNumber: String?,
        timestamp: Date,
        speed: Double,
        direction: Double
    )

    /// One lightning strike. `distance` is km.
    case lightningStrike(
        serialNumber: String,
        hubSerialNumber: String?,
        timestamp: Date,
        distance: Double,
        energy: Double
    )

    /// The rain sensor saw the first drops of a new rain event.
    case rainStart(
        serialNumber: String,
        hubSerialNumber: String?,
        date: Date
    )

    /// The once-a-minute status from a sensor: uptime, voltage, signal and
    /// any sensor problems.
    case deviceStatus(DeviceStatus)

    /// The once-a-minute status from the hub: uptime, reset flags and the
    /// radio counters.
    case hubStatus(HubStatus)
}
#endif
