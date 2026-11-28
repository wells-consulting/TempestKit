//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Talks to the WeatherFlow Tempest REST API (https://apidocs.tempestwx.com)
/// for the stations on your account.
///
/// OAuth tokens and personal access tokens look the same to the API, so the
/// client doesn't care which kind you have. It doesn't store one either. Pass
/// one with every call.
///
/// Every call is one request. The client doesn't wait between requests, cache
/// anything or retry, so how often you call is up to you. The rate limit is
/// low, so space your calls out.
public struct TempestClient: Sendable {

    /// The REST API's base URL.
    public static let baseURL = "https://swd.weatherflow.com/swd/rest"

    private let transport: any Transport

    /// `userAgent` is sent with every request. Set it to your app's name if
    /// you want WeatherFlow to know who's calling.
    public init(userAgent: String = "TempestKit") {
        self.transport = URLSessionTransport(userAgent: userAgent)
    }

    init(transport: any Transport) {
        self.transport = transport
    }

    // MARK: - Stations

    /// All the stations the token has access to.
    ///
    /// - Parameter token: Your personal access token or OAuth token.
    /// - Returns: The stations, with their devices and metadata.
    /// - Throws: `TempestError` when the request or the response fails.
    public func stations(token: String) async throws(TempestError) -> [WeatherStation] {
        try await stationSet(token: token).stations
    }

    /// All the stations plus the API's status object.
    ///
    /// - Parameter token: Your personal access token or OAuth token.
    /// - Returns: The status and the stations.
    /// - Throws: `TempestError` when the request or the response fails.
    public func stationSet(token: String) async throws(TempestError) -> StationSet {
        let response = try await send("stations", token: token, as: StationsResponseDTO.self)
        return StationSet(dto: response)
    }

    /// One station by ID.
    ///
    /// Returns nil when the response doesn't include the station. A 404 from
    /// the API still throws `TempestError.httpStatus`.
    ///
    /// - Parameters:
    ///   - id: The station's ID.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The station, or nil if the response was empty.
    /// - Throws: `TempestError` when the request or the response fails.
    public func station(
        _ id: WeatherStation.ID,
        token: String
    ) async throws(TempestError) -> WeatherStation? {
        let response = try await stationSet(id, token: token)
        return response.stations.first { $0.id == id } ?? response.stations.first
    }

    /// One station's response by ID, including the API's status object.
    ///
    /// - Parameters:
    ///   - id: The station's ID.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The status and the stations in the response.
    /// - Throws: `TempestError` when the request or the response fails.
    public func stationSet(
        _ id: WeatherStation.ID,
        token: String
    ) async throws(TempestError) -> StationSet {
        let response = try await send(
            "stations/\(id)",
            token: token,
            as: StationsResponseDTO.self,
        )
        return StationSet(dto: response)
    }

    // MARK: - Observations

    /// The station's most recent observation.
    ///
    /// The API sends back a few recent rows. If the newest one is bad (a sensor
    /// failed, say) we use the one before it instead of returning nothing.
    /// Use `latestStationObservations` if you also want the response's source
    /// and units.
    ///
    /// - Parameters:
    ///   - station: The station's ID.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The newest usable row.
    /// - Throws: `TempestError.noObservation` when no row is usable.
    public func latestObservation(
        station: WeatherStation.ID,
        token: String
    ) async throws(TempestError) -> StationObservation {
        let response = try await latestStationObservations(station: station, token: token)
        guard let observation = response.rows.last else {
            throw TempestError.noObservation
        }
        return observation
    }

    /// The station's latest response, with its source, units and status.
    ///
    /// - Parameters:
    ///   - station: The station's ID.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The status, source, units and rows.
    /// - Throws: `TempestError` when the request or the response fails.
    public func latestStationObservations(
        station: WeatherStation.ID,
        token: String
    ) async throws(TempestError) -> StationObservations {
        let response = try await send(
            "observations/stn/\(station)",
            token: token,
            as: StationObservationsResponseDTO.self,
        )
        return StationObservations(dto: response, stationID: station)
    }

    /// The station's observations for `range`, oldest first.
    ///
    /// With the default bucket you get the station's actual once-a-minute
    /// readings. A bigger bucket gets you the API's own summary rows instead
    /// (see `ObservationBucket`).
    ///
    /// One request can cover at most `bucket.maxSpan`, and a longer range
    /// throws `TempestError.rangeTooLong`. Split it with
    /// `bucket.windows(for:)` and call this once for each window.
    ///
    /// Rows missing a timestamp or temperature are dropped, so you may get
    /// fewer rows than you expect. An empty array means the station has no
    /// data for that range (maybe it wasn't installed yet). Use
    /// `stationObservations` if you also want the source and units.
    ///
    /// - Parameters:
    ///   - station: The station's ID.
    ///   - range: The range to fetch.
    ///   - bucket: How many minutes each row covers.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The rows, oldest first.
    /// - Throws: `TempestError.rangeTooLong` when the range is too long.
    public func observations(
        station: WeatherStation.ID,
        range: ClosedRange<Date>,
        bucket: ObservationBucket = .oneMinute,
        token: String
    ) async throws(TempestError) -> [StationObservation] {
        try await stationObservations(
            station: station,
            range: range,
            bucket: bucket,
            token: token
        ).rows
    }

    /// The station's response for `range`, with its source, units and status.
    ///
    /// The range limit is the same as `observations`.
    ///
    /// - Parameters:
    ///   - station: The station's ID.
    ///   - range: The range to fetch.
    ///   - bucket: How many minutes each row covers.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The status, source, units and rows.
    /// - Throws: `TempestError.rangeTooLong` when the range is too long.
    public func stationObservations(
        station: WeatherStation.ID,
        range: ClosedRange<Date>,
        bucket: ObservationBucket = .oneMinute,
        token: String
    ) async throws(TempestError) -> StationObservations {
        guard range.upperBound.timeIntervalSince(range.lowerBound) <= bucket.maxSpan else {
            throw TempestError.rangeTooLong(maxSpan: bucket.maxSpan)
        }

        let response = try await send(
            "observations/stn/\(station)",
            query: [
                URLQueryItem(name: "time_start", value: "\(Int(range.lowerBound.timeIntervalSince1970))"),
                URLQueryItem(name: "time_end", value: "\(Int(range.upperBound.timeIntervalSince1970))"),
                URLQueryItem(name: "bucket", value: "\(bucket.rawValue)"),
            ],
            token: token,
            as: StationObservationsResponseDTO.self,
        )
        return StationObservations(dto: response, stationID: station)
    }

    /// One device's readings.
    ///
    /// The endpoint returns one-minute rows for a range of five days or less.
    /// A longer range throws `TempestError.rangeTooLong(maxSpan:)`; split it
    /// with `DeviceObservationRange.windows(for:)`. Without a range you get the
    /// latest row.
    ///
    /// - Parameters:
    ///   - device: The device's ID.
    ///   - range: The latest row, a UTC day, or a range. Defaults to `.latest`.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The rows, the row type, the source and the summary.
    /// - Throws: `TempestError` when the request or the response fails.
    public func deviceObservations(
        device: WeatherStation.Device.ID,
        range: DeviceObservationRange = .latest,
        token: String
    ) async throws(TempestError) -> DeviceObservations {
        let path = "observations/device/\(device)"
        let response = try await send(
            path,
            query: try range.queryItems(),
            token: token,
            as: DeviceObservationsResponseDTO.self,
        )
        return DeviceObservations(dto: response, deviceID: device)
    }

    /// The CSV version of `deviceObservations`.
    ///
    /// The API sends the text as-is. The same five-day limit applies.
    ///
    /// - Parameters:
    ///   - device: The device's ID.
    ///   - range: The latest row, a UTC day, or a range. Defaults to `.latest`.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The CSV text.
    /// - Throws: `TempestError` when the request fails, or when the response
    ///   isn't text or looks like JSON.
    public func deviceObservationsCSV(
        device: WeatherStation.Device.ID,
        range: DeviceObservationRange = .latest,
        token: String
    ) async throws(TempestError) -> String {
        let path = "observations/device/\(device)"
        let data = try await sendData(
            path,
            query: try range.queryItems() + [URLQueryItem(name: "format", value: "csv")],
            token: token,
        )
        guard let text = String(data: data, encoding: .utf8) else {
            throw .decoding(path: path, message: "The response wasn't UTF-8 text.")
        }
        let first = text.drop(while: { $0.isWhitespace }).first
        guard first != "{" && first != "[" else {
            throw .decoding(path: path, message: "Expected CSV, got JSON.")
        }
        return text
    }

    /// The station's current conditions.
    ///
    /// This isn't the same as `latestObservation`. It combines all of the
    /// station's devices and includes values the API calculates, like feels
    /// like, dew point and pressure trend.
    public func conditions(
        station: WeatherStation.ID,
        token: String
    ) async throws(TempestError) -> StationConditions {
        let response = try await send(
            "observations/station/\(station)",
            token: token,
            as: StationConditionsResponseDTO.self,
        )
        guard let conditions = StationConditions(dto: response) else {
            throw TempestError.noObservation
        }
        return conditions
    }

    // MARK: - Statistics

    /// A summary of every day the station has data for.
    ///
    /// This is one request for the station's whole history, so it's a cheap
    /// way to find out how much data there is or what each day looked like.
    public func statistics(
        station: WeatherStation.ID,
        token: String
    ) async throws(TempestError) -> StationStatistics {
        let response = try await send(
            "stats/station/\(station)",
            token: token,
            as: StationStatsResponseDTO.self,
        )
        return StationStatistics(dto: response)
    }

    // MARK: - Forecast

    /// The station's forecast: current conditions, hourly, and daily.
    ///
    /// All three come back in one response, so if you show both the hours and
    /// the days, ask once and use the same forecast for both. The values are
    /// in `units`, which defaults to metric.
    ///
    /// The API can also forecast for a latitude and longitude, but only with
    /// a paid TempestOne token. Personal tokens get a 401, so we only support
    /// forecasts by station.
    ///
    /// - Parameters:
    ///   - station: The station to forecast for.
    ///   - units: The units you want the values in. Defaults to `.metric`.
    ///   - token: Your personal access token or OAuth token.
    /// - Returns: The current conditions, hours and days.
    /// - Throws: `TempestError` when the request or the response fails.
    public func forecast(
        station: WeatherStation.ID,
        units: Units = .metric,
        token: String
    ) async throws(TempestError) -> TempestForecast {
        let response = try await send(
            "better_forecast",
            query: [URLQueryItem(name: "station_id", value: "\(station)")] + units.queryItems,
            token: token,
            as: BetterForecastResponseDTO.self,
        )
        return TempestForecast(dto: response, units: units)
    }

    // MARK: - Requests

    // The errors carry the path but never the query, since the query has the
    // token in it.
    //
    // @concurrent so the URL building, the request and the JSON decode run off
    // the caller's actor. The public methods stay nonsending: they only map the
    // decoded values into our types.
    @concurrent
    private func sendData(
        _ path: String,
        query: [URLQueryItem] = [],
        token: String
    ) async throws(TempestError) -> Data {
        guard
            let url = Self.url(
                path: path,
                query: query + [URLQueryItem(name: "token", value: token)],
            )
        else {
            throw TempestError.invalidRequest
        }

        let (data, statusCode) = try await transport.get(url)

        // Failure is not an option

        switch statusCode {
        case 200...299:
            break
        case 401:
            throw TempestError.unauthorized
        case 429:
            throw TempestError.rateLimited
        default:
            throw TempestError.httpStatus(code: statusCode, path: path)
        }

        return data
    }

    @concurrent
    private func send<Value: Decodable>(
        _ path: String,
        query: [URLQueryItem] = [],
        token: String,
        as type: Value.Type
    ) async throws(TempestError) -> Value {
        let data = try await sendData(path, query: query, token: token)

        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            throw TempestError.decoding(path: path, message: String(describing: error))
        }
    }

    private static func url(path: String, query: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(string: baseURL) else { return nil }

        components.path += "/" + path
        components.queryItems = query
        return components.url
    }
}
