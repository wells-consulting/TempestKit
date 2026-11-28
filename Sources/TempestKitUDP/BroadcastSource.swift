//
// TempestKitUDP
// Copyright 2026 Wells Consulting. MIT licensed.
//

#if canImport(Network)
import Foundation
import Network
import TempestKit

// Feeds the public stream. Split out so tests can hand `TempestUDP` readings
// without opening a socket.
protocol BroadcastSource: Sendable {

    func broadcasts() throws(TempestError) -> AsyncThrowingStream<TempestBroadcast, any Error>
}

struct UDPBroadcasts: BroadcastSource {

    let stationID: WeatherStation.ID
    let hubSerialNumber: String
    let port: UInt16

    // One queue for every listener in the process. A callback does a small
    // JSON decode and gets out of the way.
    private static let queue = DispatchQueue(label: "TempestKitUDP")

    func broadcasts() throws(TempestError) -> AsyncThrowingStream<TempestBroadcast, any Error> {
        guard port > 0, let nwPort = NWEndpoint.Port(rawValue: port) else {
            throw .listeningFailed(port: port, reason: "not a usable port")
        }

        let parameters = NWParameters.udp
        parameters.allowLocalEndpointReuse = true

        let listener: NWListener
        do {
            listener = try NWListener(using: parameters, on: nwPort)
        } catch {
            throw .listeningFailed(port: port, reason: error.localizedDescription)
        }

        let parser = BroadcastParser(stationID: stationID, hubSerialNumber: hubSerialNumber)
        let open = OpenConnections()

        return AsyncThrowingStream { continuation in
            listener.stateUpdateHandler = { state in
                switch state {
                case .failed(let error):
                    continuation.finish(throwing: TempestError.listeningFailed(
                        port: port,
                        reason: error.localizedDescription
                    ))
                case .cancelled:
                    continuation.finish()
                default:
                    break
                }
            }

            listener.newConnectionHandler = { connection in
                open.add(connection)
                let receiver = Receiver(
                    connection: connection,
                    parser: parser,
                    open: open,
                    queue: UDPBroadcasts.queue
                ) { broadcast in
                    continuation.yield(broadcast)
                }
                receiver.start()
            }

            continuation.onTermination = { _ in
                // The listener holds these closures and the closures hold the
                // continuation, so the loop has to be broken before letting go.
                listener.newConnectionHandler = nil
                listener.stateUpdateHandler = nil
                listener.cancel()
                open.cancelAll()
            }

            listener.start(queue: UDPBroadcasts.queue)
        }
    }
}

// The hub gets a connection per source address, and the listener doesn't close
// them when it stops, so we keep them here and cancel them on the way out.
private final class OpenConnections: @unchecked Sendable {

    // The lock covers the dictionary
    private let lock = NSLock()
    private var connections: [ObjectIdentifier: NWConnection] = [:]

    func add(_ connection: NWConnection) {
        lock.withLock {
            connections[ObjectIdentifier(connection)] = connection
        }
    }

    func remove(_ connection: NWConnection) {
        lock.withLock {
            connections[ObjectIdentifier(connection)] = nil
        }
    }

    func cancelAll() {
        let all = lock.withLock {
            let all = Array(connections.values)
            connections.removeAll()
            return all
        }
        for connection in all {
            connection.cancel()
        }
    }
}

private final class Receiver: Sendable {

    private let connection: NWConnection
    private let parser: BroadcastParser
    private let open: OpenConnections
    private let queue: DispatchQueue
    private let yield: @Sendable (TempestBroadcast) -> Void

    init(
        connection: NWConnection,
        parser: BroadcastParser,
        open: OpenConnections,
        queue: DispatchQueue,
        yield: @escaping @Sendable (TempestBroadcast) -> Void
    ) {
        self.connection = connection
        self.parser = parser
        self.open = open
        self.queue = queue
        self.yield = yield
    }

    func start() {
        connection.stateUpdateHandler = { [self] state in
            if case .failed = state {
                stop()
            }
        }
        connection.start(queue: queue)
        receive()
    }

    // Every datagram needs another receive, so this calls itself. The stack
    // doesn't grow because each call comes back through the callback.
    private func receive() {
        connection.receiveMessage { [self] data, _, _, error in
            if let data {
                for broadcast in parser.parse(data) {
                    yield(broadcast)
                }
            }
            if error == nil {
                receive()
            } else {
                stop()
            }
        }
    }

    private func stop() {
        open.remove(connection)
        connection.cancel()
    }
}
#endif
