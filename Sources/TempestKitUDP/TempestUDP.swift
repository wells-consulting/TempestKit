//
// TempestKitUDP
// Copyright 2026 Wells Consulting. MIT licensed.
//

#if canImport(Network)
import Foundation
import Network
import TempestKit

/// Live readings from a station on your local network.
///
/// The hub broadcasts on port 50222 and needs no token. Only one listener can
/// use the port on a device at a time, so if something else already has it the
/// stream finishes with `TempestError.listeningFailed`.
///
/// On iOS and visionOS this needs the multicast networking entitlement, which
/// Apple has to grant. macOS doesn't need it, but macOS 15 and later ask the
/// person using the app for local network access. If they say no, nothing
/// arrives.
public struct TempestUDP: Sendable {

    /// The port every hub broadcasts on.
    public static let defaultPort: UInt16 = 50222

    private let source: any BroadcastSource

    /// A listener for one station's hub.
    ///
    /// `hubSerialNumber` is the hub's serial, the `HB-…` one. Filtering on the
    /// hub gets every device on the station, including an Air and a Sky. Get
    /// it from `WeatherStation.hub?.serialNumber`.
    public init(
        station: WeatherStation.ID,
        hubSerialNumber: String,
        port: UInt16 = TempestUDP.defaultPort
    ) {
        self.source = UDPBroadcasts(
            stationID: station,
            hubSerialNumber: hubSerialNumber,
            port: port
        )
    }

    // So tests can feed broadcasts in without a socket
    init(source: any BroadcastSource) {
        self.source = source
    }

    /// The station's broadcasts, starting when you iterate and stopping when
    /// the task is canceled.
    ///
    /// The stream finishes with `TempestError.listeningFailed` when the port
    /// can't be opened.
    public func listen() throws(TempestError) -> AsyncThrowingStream<TempestBroadcast, any Error> {
        try source.broadcasts()
    }
}
#endif
