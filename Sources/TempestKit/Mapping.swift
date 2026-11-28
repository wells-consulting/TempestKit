//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

// Converts API responses into our models. Internal so tests can decode
// saved JSON without hitting the network.

extension WeatherStation {

    init(dto: StationDTO) {
        self.init(
            id: dto.stationID,
            locationID: dto.locationID,
            name: dto.name,
            publicName: dto.publicName,
            latitude: dto.latitude,
            longitude: dto.longitude,
            timeZone: dto.timeZoneIdentifier.flatMap(TimeZone.init(identifier:)),
            timezoneOffsetMinutes: dto.timezoneOffsetMinutes,
            elevation: dto.stationMeta?.elevation,
            sharesWithWeatherFlow: dto.stationMeta?.shareWithWeatherFlow,
            sharesWithWeatherUnderground: dto.stationMeta?.shareWithWeatherUnderground,
            isLocalMode: dto.isLocalMode,
            capabilities: dto.capabilities.compactMap(WeatherStation.Capability.init(dto:)),
            state: dto.state,
            devices: dto.devices.map { device in
                WeatherStation.Device(
                    id: device.id,
                    deviceType: WeatherStation.DeviceType(code: device.deviceType),
                    serialNumber: device.serialNumber,
                    firmwareRevision: device.firmwareRevision,
                    hardwareRevision: device.hardwareRevision,
                    notes: device.notes,
                    meta: device.meta.map(WeatherStation.Device.Meta.init(dto:)),
                    settings: device.settings.map(WeatherStation.Device.Settings.init(dto:)),
                )
            },
            items: dto.stationItems.compactMap(WeatherStation.Item.init(dto:)),
            createdAt: dto.createdEpoch.map { Date(timeIntervalSince1970: $0) },
            lastModified: dto.lastModifiedEpoch.map { Date(timeIntervalSince1970: $0) },
        )
    }
}

extension StationSet {

    init(dto: StationsResponseDTO) {
        self.init(
            status: dto.status.map(ResponseStatus.init(dto:)),
            stations: dto.stations.map(WeatherStation.init(dto:))
        )
    }
}

extension WeatherStation.Capability {

    // A capability without a name doesn't say which sensor it is, so drop it.
    init?(dto: StationCapabilityDTO) {
        guard let name = dto.name, !name.isEmpty else { return nil }
        self.init(
            name: name,
            deviceID: dto.deviceID,
            environment: dto.environment.map(WeatherStation.Device.Environment.init(code:)),
            heightAboveGround: dto.heightAboveGround,
            showsPrecipitationFinal: dto.showsPrecipitationFinal
        )
    }
}

extension ResponseStatus {

    init(dto: ResponseStatusDTO) {
        self.init(code: dto.code, message: dto.message)
    }
}

extension WeatherStation.Device.Meta {

    init(dto: DeviceMetaDTO) {
        self.init(
            heightAboveGround: dto.heightAboveGround,
            name: dto.name,
            environment: dto.environment.map(WeatherStation.Device.Environment.init(code:)),
            wifiNetworkName: dto.wifiNetworkName,
        )
    }
}

extension WeatherStation.Device.Settings {

    init(dto: DeviceSettingsDTO) {
        self.init(showsPrecipitationFinal: dto.showsPrecipitationFinal)
    }
}

extension WeatherStation.Item {

    // An item without a name doesn't say which sensor it is, so drop it.
    init?(dto: StationItemDTO) {
        guard let name = dto.name, !name.isEmpty else { return nil }
        self.init(
            locationItemID: dto.locationItemID,
            stationItemID: dto.stationItemID,
            stationID: dto.stationID,
            locationID: dto.locationID,
            deviceID: dto.deviceID,
            name: name,
            sort: dto.sort,
        )
    }
}

extension StationObservation {

    // Maps one observation row by position, for when the response doesn't
    // tell us the field names. This is the order the API used when we
    // checked it:
    //
    //   timestamp, report_interval (min), wind_lull, wind_avg, wind_gust (m/s),
    //   wind_direction (°), station_pressure (MB), sea_level_pressure (MB),
    //   air_temp (°C), rh (%), illuminance (lux), uv, solar_radiation (W/m²),
    //   precip_accumulation (mm), local day precip (mm), precip_type,
    //   strike_count, strike_distance (km), nearcast precip (mm),
    //   nearcast local day precip (mm)
    //
    // Note this is the station row (obs_station), not the device row (obs_st).
    // They're different. The station row starts with the report interval and
    // has sea level pressure.
    //
    // No timestamp or temperature means we drop the row. If a sensor failed
    // we want nil, not zero. Same reason a short row just leaves the missing
    // fields nil.
    init?(row: [Double?], stationID: WeatherStation.ID) {
        func value(at index: Int) -> Double? {
            index < row.count ? row[index] : nil
        }
        guard let timestamp = value(at: 0), let temperature = value(at: 8) else {
            return nil
        }
        self.init(
            stationID: stationID,
            timestamp: Date(timeIntervalSince1970: timestamp),
            reportInterval: value(at: 1),
            windSampleInterval: nil,
            windLull: value(at: 2),
            windAverage: value(at: 3),
            windGust: value(at: 4),
            windDirection: value(at: 5),
            stationPressure: value(at: 6),
            seaLevelPressure: value(at: 7),
            airTemperature: temperature,
            relativeHumidity: value(at: 9),
            illuminance: value(at: 10),
            uvIndex: value(at: 11),
            solarRadiation: value(at: 12),
            precipitation: value(at: 13),
            localDayPrecipitation: value(at: 14),
            precipitationType: value(at: 15).flatMap(Int.init(exactly:)).map(PrecipitationType.init(code:)),
            lightningStrikeCount: value(at: 16).map { Int($0) },
            lightningStrikeDistance: value(at: 17),
            nearcastPrecipitation: value(at: 18),
            nearcastLocalDayPrecipitation: value(at: 19),
            precipitationAnalysis: nil,
            batteryVoltage: nil,
        )
    }
}

extension TempestForecast {

    init(dto: BetterForecastResponseDTO, units: Units) {
        self.init(
            currentConditions: dto.currentConditions.flatMap(TempestForecast.CurrentConditions.init(dto:)),
            hours: (dto.forecast?.hourly ?? []).compactMap(TempestForecast.Hour.init(dto:)),
            days: (dto.forecast?.daily ?? []).compactMap(TempestForecast.Day.init(dto:)),
            locationName: dto.locationName,
            timeZone: dto.timeZoneIdentifier.flatMap(TimeZone.init(identifier:)),
            latitude: dto.latitude,
            longitude: dto.longitude,
            timezoneOffsetMinutes: dto.timezoneOffsetMinutes,
            units: units,
            sourceIDConditions: dto.sourceIDConditions,
            buildCode: dto.buildCode?.value,
            refreshIntervalSeconds: dto.refreshIntervalSeconds,
            responseUnits: dto.units.map(DisplayUnits.init(dto:)),
            station: dto.station.map(TempestForecast.Station.init(dto:)),
            status: dto.status.map(ResponseStatus.init(dto:)),
        )
    }
}

extension TempestForecast.Station {

    init(dto: ForecastStationDTO) {
        self.init(
            id: dto.id,
            heightAboveGround: dto.heightAboveGround,
            elevation: dto.elevation,
            isStationOnline: dto.isStationOnline,
            state: dto.state
        )
    }
}

extension TempestForecast.CurrentConditions {

    // No time means we can't tell when this was, so skip it
    init?(dto: ForecastCurrentConditionsDTO) {
        guard let time = dto.time else { return nil }
        self.init(
            timestamp: Date(timeIntervalSince1970: TimeInterval(time)),
            conditions: dto.conditions,
            icon: dto.icon.map(TempestForecast.Icon.init(rawValue:)),
            airTemperature: dto.airTemperature,
            stationPressure: dto.stationPressure,
            seaLevelPressure: dto.seaLevelPressure,
            pressureTrend: dto.pressureTrend.flatMap(PressureTrend.init(rawValue:)),
            relativeHumidity: dto.relativeHumidity,
            precipitationChance: dto.precipitationProbability,
            windAverage: dto.windAverage,
            windGust: dto.windGust,
            windDirection: dto.windDirection,
            windDirectionCardinal: dto.windDirectionCardinal.map(CompassPoint.init(rawValue:)),
            windDirectionIcon: dto.windDirectionIcon,
            solarRadiation: dto.solarRadiation,
            uvIndex: dto.uvIndex,
            illuminance: dto.illuminance,
            feelsLike: dto.feelsLike,
            dewPoint: dto.dewPoint,
            wetBulb: dto.wetBulbTemperature,
            wetBulbGlobe: dto.wetBulbGlobeTemperature,
            deltaT: dto.deltaT,
            airDensity: dto.airDensity,
            lightningStrikeCountLastHour: dto.lightningStrikeCountLastHour,
            lightningStrikeCountLastThreeHours: dto.lightningStrikeCountLastThreeHours,
            lightningStrikeLastDistance: dto.lightningStrikeLastDistance,
            lightningStrikeLastDistanceMessage: dto.lightningStrikeLastDistanceMessage,
            lightningStrikeLastTime: dto.lightningStrikeLastEpoch.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            precipitationToday: dto.precipitationToday,
            precipitationYesterday: dto.precipitationYesterday,
            precipitationMinutesToday: dto.precipitationMinutesToday,
            precipitationMinutesYesterday: dto.precipitationMinutesYesterday,
            precipitationTodayIsRainCheck: dto.precipitationTodayIsRainCheck,
            precipitationYesterdayIsRainCheck: dto.precipitationYesterdayIsRainCheck,
            includesStationData: dto.includesStationData,
        )
    }
}

extension TempestForecast.Hour {

    // No time means we can't put it on the timeline, so skip it. Everything
    // else is optional, since an hour with a few missing values is still
    // useful.
    init?(dto: BetterForecastHourDTO) {
        guard let time = dto.time else { return nil }
        self.init(
            timestamp: Date(timeIntervalSince1970: TimeInterval(time)),
            icon: dto.icon.map(TempestForecast.Icon.init(rawValue:)),
            conditions: dto.conditions,
            airTemperature: dto.airTemperature,
            relativeHumidity: dto.relativeHumidity,
            stationPressure: dto.stationPressure,
            seaLevelPressure: dto.seaLevelPressure,
            precipitation: dto.precipitation,
            precipitationChance: dto.precipitationProbability,
            precipitationType: dto.precipitationType.map(TempestForecast.PrecipitationType.init(rawValue:)),
            precipitationIcon: dto.precipitationIcon.map(TempestForecast.PrecipitationIcon.init(rawValue:)),
            windAverage: dto.windAverage,
            windAverageColor: dto.windAverageColor,
            windGust: dto.windGust,
            windGustColor: dto.windGustColor,
            windDirection: dto.windDirection,
            windDirectionCardinal: dto.windDirectionCardinal.map(CompassPoint.init(rawValue:)),
            windDirectionIcon: dto.windDirectionIcon,
            uvIndex: dto.uvIndex,
            feelsLike: dto.feelsLike,
            localHour: dto.localHour,
            localDay: dto.localDay,
        )
    }
}

extension TempestForecast.Day {

    // No start time means we don't know which day it is, so skip it. A day
    // that's missing its high or low keeps the other one.
    init?(dto: BetterForecastDayDTO) {
        guard let start = dto.dayStartLocal else { return nil }
        self.init(
            date: Date(timeIntervalSince1970: TimeInterval(start)),
            dayNumber: dto.dayNumber,
            monthNumber: dto.monthNumber,
            icon: dto.icon.map(TempestForecast.Icon.init(rawValue:)),
            conditions: dto.conditions,
            highTemperature: dto.highTemperature,
            lowTemperature: dto.lowTemperature,
            highTemperatureColor: dto.highTemperatureColor,
            lowTemperatureColor: dto.lowTemperatureColor,
            precipitationChance: dto.precipitationProbability,
            precipitationType: dto.precipitationType.map(TempestForecast.PrecipitationType.init(rawValue:)),
            precipitationIcon: dto.precipitationIcon.map(TempestForecast.PrecipitationIcon.init(rawValue:)),
            sunrise: dto.sunrise.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            sunset: dto.sunset.map { Date(timeIntervalSince1970: TimeInterval($0)) },
        )
    }
}

extension StationObservation {

    // Maps one observation row using the field names the API sends back in
    // ob_fields. This is the normal path. The positional version above is
    // only for responses that leave ob_fields out.
    //
    // WeatherFlow doesn't document these names. These are the ones the API
    // sent back when we checked. A name we don't know is just ignored, so it
    // can't shift the other values out of place.
    init?(row: [Double?], fields: [String]?, stationID: WeatherStation.ID) {
        guard let fields else {
            self.init(row: row, stationID: stationID)
            return
        }
        var positions: [String: Int] = [:]
        for (position, name) in fields.enumerated() {
            positions[name] = position
        }
        func value(_ name: String) -> Double? {
            guard let position = positions[name], position < row.count else { return nil }
            return row[position]
        }
        guard
            let timestamp = value("timestamp"),
            let temperature = value("air_temp")
        else {
            return nil
        }
        self.init(
            stationID: stationID,
            timestamp: Date(timeIntervalSince1970: timestamp),
            reportInterval: value("report_interval"),
            windSampleInterval: value("wind_sample_interval"),
            windLull: value("wind_lull"),
            windAverage: value("wind_avg"),
            windGust: value("wind_gust"),
            windDirection: value("wind_dir"),
            stationPressure: value("station_pressure"),
            seaLevelPressure: value("sea_level_pressure"),
            airTemperature: temperature,
            relativeHumidity: value("rh"),
            illuminance: value("illuminance"),
            uvIndex: value("uv"),
            solarRadiation: value("solar_radiation"),
            precipitation: value("precip_accumulation"),
            localDayPrecipitation: value("local_day_precip_accumulation"),
            precipitationType: value("precip_type")
                .flatMap(Int.init(exactly:))
                .map(PrecipitationType.init(code:)),
            lightningStrikeCount: value("strike_count").map { Int($0) },
            lightningStrikeDistance: value("strike_distance"),
            nearcastPrecipitation: value("nc_precip_accumulation"),
            nearcastLocalDayPrecipitation: value("nc_local_day_precip_accumulation"),
            precipitationAnalysis: value("precip_analysis_type")
                .flatMap(Int.init(exactly:))
                .map(PrecipitationAnalysis.init(code:)),
            batteryVoltage: value("battery"),
        )
    }
}

extension StationConditions {

    // Uses the newest row that has a timestamp. No such row, no conditions.
    init?(dto: StationConditionsResponseDTO) {
        let dated = dto.observations.compactMap { row -> (row: StationConditionValuesDTO, date: Date)? in
            guard let timestamp = row.timestamp else { return nil }
            return (row, Date(timeIntervalSince1970: TimeInterval(timestamp)))
        }
        guard let newest = dated.max(by: { $0.date < $1.date }) else { return nil }

        let row = newest.row
        self.init(
            status: dto.status.map(ResponseStatus.init(dto:)),
            stationID: dto.stationID,
            stationName: dto.stationName,
            publicName: dto.publicName,
            isPublic: dto.isPublic,
            timeZone: dto.timeZoneIdentifier.flatMap(TimeZone.init(identifier:)),
            latitude: dto.latitude,
            longitude: dto.longitude,
            elevation: dto.elevation,
            displayUnits: dto.units.map(DisplayUnits.init(dto:)),
            timestamp: newest.date,
            airTemperature: row.airTemperature,
            stationPressure: row.stationPressure ?? row.barometricPressure,
            seaLevelPressure: row.seaLevelPressure,
            relativeHumidity: row.relativeHumidity,
            windLull: row.windLull,
            windAverage: row.windAverage,
            windGust: row.windGust,
            windDirection: row.windDirection,
            illuminance: row.illuminance,
            uvIndex: row.uvIndex,
            solarRadiation: row.solarRadiation,
            precipitation: row.precipitation,
            precipitationLastHour: row.precipitationLastHour,
            precipitationToday: row.precipitationToday,
            precipitationTodayFinal: row.precipitationTodayFinal,
            precipitationYesterday: row.precipitationYesterday,
            precipitationYesterdayFinal: row.precipitationYesterdayFinal,
            precipitationMinutesToday: row.precipitationMinutesToday,
            precipitationMinutesYesterday: row.precipitationMinutesYesterday,
            precipitationMinutesYesterdayFinal: row.precipitationMinutesYesterdayFinal,
            precipitationAnalysisTypeYesterday: row.precipitationAnalysisTypeYesterday
                .map(PrecipitationAnalysis.init(code:)),
            lightningStrikeLastTime: row.lightningStrikeLastEpoch.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            lightningStrikeLastDistance: row.lightningStrikeLastDistance,
            lightningStrikeCount: row.lightningStrikeCount,
            lightningStrikeCountLastHour: row.lightningStrikeCountLastHour,
            lightningStrikeCountLastThreeHours: row.lightningStrikeCountLastThreeHours,
            outdoorKeys: dto.outdoorKeys,
            indoor: StationConditions.Indoor(dto: row),
            calculated: CalculatedValues(
                feelsLike: row.feelsLike,
                heatIndex: row.heatIndex,
                windChill: row.windChill,
                dewPoint: row.dewPoint,
                wetBulb: row.wetBulbTemperature,
                wetBulbGlobe: row.wetBulbGlobeTemperature,
                deltaT: row.deltaT,
                airDensity: row.airDensity,
                pressureTrend: row.pressureTrend.flatMap(PressureTrend.init(rawValue:)),
            ),
        )
    }
}

extension StationConditions.Indoor {

    // No indoor fields at all means the station doesn't have an indoor
    // device, so leave the whole value nil.
    init?(dto: StationConditionValuesDTO) {
        guard dto.hasIndoorValues else { return nil }
        self.init(
            airTemperature: dto.airTemperatureIndoor,
            stationPressure: dto.stationPressureIndoor,
            seaLevelPressure: dto.seaLevelPressureIndoor,
            relativeHumidity: dto.relativeHumidityIndoor,
            precipitation: dto.precipitationIndoor,
            precipitationLastHour: dto.precipitationLastHourIndoor,
            windLull: dto.windLullIndoor,
            windAverage: dto.windAverageIndoor,
            windGust: dto.windGustIndoor,
            windDirection: dto.windDirectionIndoor,
            illuminance: dto.illuminanceIndoor,
            uvIndex: dto.uvIndexIndoor,
            solarRadiation: dto.solarRadiationIndoor,
            lightningStrikeLastTime: dto.lightningStrikeLastEpochIndoor
                .map { Date(timeIntervalSince1970: TimeInterval($0)) },
            lightningStrikeLastDistance: dto.lightningStrikeLastDistanceIndoor,
            lightningStrikeCountLastThreeHours: dto.lightningStrikeCountLastThreeHoursIndoor,
            calculated: CalculatedValues(
                feelsLike: dto.feelsLikeIndoor,
                heatIndex: dto.heatIndexIndoor,
                windChill: dto.windChillIndoor,
                dewPoint: dto.dewPointIndoor,
                wetBulb: dto.wetBulbTemperatureIndoor,
                wetBulbGlobe: nil,
                deltaT: dto.deltaTIndoor,
                airDensity: dto.airDensityIndoor,
                pressureTrend: nil,
            ),
        )
    }
}

extension StationObservations {

    init(dto: StationObservationsResponseDTO, stationID: WeatherStation.ID) {
        self.init(
            status: dto.status.map(ResponseStatus.init(dto:)),
            stationID: dto.stationID ?? stationID,
            type: dto.type ?? "",
            source: dto.source,
            units: dto.units.map(DisplayUnits.init(dto:)),
            fields: dto.obFields,
            rows: dto.obs.compactMap {
                StationObservation(row: $0, fields: dto.obFields, stationID: stationID)
            }
        )
    }
}

extension DeviceObservations {

    init(dto: DeviceObservationsResponseDTO, deviceID: WeatherStation.Device.ID) {
        let type = dto.type ?? ""
        let rowType = DeviceObservation.RowType(rawValue: type)
        self.init(
            status: dto.status.map(ResponseStatus.init(dto:)),
            deviceID: dto.deviceID ?? deviceID,
            type: type,
            source: dto.source,
            summary: dto.summary.map(DeviceSummary.init(dto:)),
            rows: rowType.map { type in
                dto.observations.compactMap { DeviceObservation(row: $0, type: type) }
            } ?? [],
        )
    }
}

extension DeviceSummary {

    init(dto: DeviceObservationSummaryDTO) {
        self.init(
            lightningStrikeCountLastHour: dto.lightningStrikeCountLastHour,
            lightningStrikeCountLastThreeHours: dto.lightningStrikeCountLastThreeHours,
            precipitationLastHour: dto.precipitationLastHour,
            lightningStrikeLastDistance: dto.lightningStrikeLastDistance,
            lightningStrikeLastTime: dto.lightningStrikeLastEpoch
                .map { Date(timeIntervalSince1970: TimeInterval($0)) },
            precipitationYesterday: dto.precipitationYesterday,
            precipitationYesterdayFinal: dto.precipitationYesterdayFinal,
            precipitationAnalysisTypeYesterday: dto.precipitationAnalysisTypeYesterday
                .map(PrecipitationAnalysis.init(code:)),
            precipitationMinutesToday: dto.precipitationMinutesToday,
            precipitationMinutesYesterday: dto.precipitationMinutesYesterday,
            calculated: CalculatedValues(
                feelsLike: dto.feelsLike,
                heatIndex: dto.heatIndex,
                windChill: dto.windChill,
                dewPoint: dto.dewPoint,
                wetBulb: dto.wetBulbTemperature,
                wetBulbGlobe: dto.wetBulbGlobeTemperature,
                deltaT: dto.deltaT,
                airDensity: dto.airDensity,
                pressureTrend: dto.pressureTrend.flatMap(PressureTrend.init(rawValue:)),
            ),
        )
    }
}

extension DisplayUnits {

    init(dto: DisplayUnitsDTO) {
        self.init(
            temperature: dto.temperature.flatMap(Units.Temperature.init(rawValue:)),
            wind: dto.wind.flatMap(Units.Wind.init(rawValue:)),
            precipitation: dto.precipitation.flatMap(Units.Precipitation.init(rawValue:)),
            pressure: dto.pressure.flatMap(Units.Pressure.init(rawValue:)),
            distance: dto.distance.flatMap(Units.Distance.init(rawValue:)),
            direction: dto.direction.flatMap(Direction.init(rawValue:)),
            brightness: dto.brightness,
            solarRadiation: dto.solarRadiation,
            airDensity: dto.airDensity,
            other: dto.other,
        )
    }
}

extension StationStatistics {

    init(dto: StationStatsResponseDTO) {
        self.init(
            status: dto.status.map(ResponseStatus.init(dto:)),
            type: dto.type,
            stationID: dto.stationID,
            firstObservationDay: dto.firstObservationLocalDay.flatMap(Self.localDay(from:)),
            lastObservationDay: dto.lastObservationLocalDay.flatMap(Self.localDay(from:)),
            days: dto.days.compactMap(StationStatistics.Day.init(dto:)),
            weeks: dto.weeks.compactMap(StationStatistics.Day.init(dto:)),
            months: dto.months.compactMap(StationStatistics.Day.init(dto:)),
            years: dto.years.compactMap(StationStatistics.Day.init(dto:)),
            allTime: dto.allTime.flatMap(StationStatistics.Day.init(dto:)),
            weekTimes: dto.weeksTimes.compactMap(StationStatistics.Times.init(dto:)),
            monthTimes: dto.monthsTimes.compactMap(StationStatistics.Times.init(dto:)),
            yearTimes: dto.yearsTimes.compactMap(StationStatistics.Times.init(dto:)),
            allTimeTimes: dto.allTimeTimes.flatMap(StationStatistics.Times.init(dto:)),
        )
    }

    // The API sends local days like "2022-03-14" with no time zone. Turning
    // that into a Date would mean guessing a zone, so we keep it as plain
    // year/month/day.
    static func localDay(from string: String) -> DateComponents? {
        let parts = string.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return DateComponents(year: parts[0], month: parts[1], day: parts[2])
    }
}

extension StationStatistics.Times {

    init?(dto: StationStatsTimeDTO) {
        guard !dto.values.isEmpty else { return nil }
        let dates = dto.values.map {
            $0.text.flatMap(StationStatistics.localDay(from:))
        }
        self.init(
            periodStart: dates.first ?? nil,
            columns: Array(dates.dropFirst())
        )
    }
}

extension StationStatistics.Day {

    // One stats_day row. The API docs list the order: pressure, temperature,
    // humidity, lux, UV and solar (each as average, high, low), then wind,
    // lightning, record count, battery and rain.
    //
    // A row without a date we can read gets dropped. We don't guess.
    init?(dto: StationStatsDayDTO) {
        guard let date = dto.date.flatMap(StationStatistics.localDay(from:)) else { return nil }
        let row = dto.values
        func value(at index: Int) -> Double? {
            index < row.count ? row[index] : nil
        }
        self.init(
            date: date,
            pressure: value(at: 0),
            pressureHigh: value(at: 1),
            pressureLow: value(at: 2),
            temperature: value(at: 3),
            temperatureHigh: value(at: 4),
            temperatureLow: value(at: 5),
            relativeHumidity: value(at: 6),
            relativeHumidityHigh: value(at: 7),
            relativeHumidityLow: value(at: 8),
            illuminance: value(at: 9),
            illuminanceHigh: value(at: 10),
            illuminanceLow: value(at: 11),
            uvIndex: value(at: 12),
            uvIndexHigh: value(at: 13),
            uvIndexLow: value(at: 14),
            solarRadiation: value(at: 15),
            solarRadiationHigh: value(at: 16),
            solarRadiationLow: value(at: 17),
            windAverage: value(at: 18),
            windGust: value(at: 19),
            windLull: value(at: 20),
            windDirection: value(at: 21),
            windSampleInterval: value(at: 22),
            lightningStrikeCount: value(at: 23),
            lightningStrikeAverageDistance: value(at: 24),
            recordCount: value(at: 25),
            batteryVoltage: value(at: 26),
            precipitation: value(at: 27),
            precipitationFinal: value(at: 28),
            precipitationMinutes: value(at: 29),
            precipitationMinutesFinal: value(at: 30),
            precipitationType: value(at: 31).flatMap(Int.init(exactly:)).map(PrecipitationType.init(code:)),
            precipitationAnalysisType: value(at: 32).flatMap(Int.init(exactly:)).map(PrecipitationAnalysis.init(code:)),
        )
    }
}
