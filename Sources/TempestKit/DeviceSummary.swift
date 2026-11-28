//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The derived values `/observations/device` sends along with its latest row.
///
/// Metric: °C for the calculated temperatures and mm for rain. The device
/// endpoint only sends these for the most recent row.
public struct DeviceSummary: Hashable, Sendable {

    /// Strikes in the last hour.
    public let lightningStrikeCountLastHour: Int?
    /// Strikes in the last three hours.
    public let lightningStrikeCountLastThreeHours: Int?
    /// mm
    public let precipitationLastHour: Double?
    /// km
    public let lightningStrikeLastDistance: Double?
    /// When the last strike happened.
    public let lightningStrikeLastTime: Date?
    /// mm
    public let precipitationYesterday: Double?
    /// Yesterday's rain after RainCheck, mm
    public let precipitationYesterdayFinal: Double?
    /// Which RainCheck correction was applied to yesterday's total
    public let precipitationAnalysisTypeYesterday: PrecipitationAnalysis?
    /// Minutes of rain today.
    public let precipitationMinutesToday: Int?
    /// Minutes of rain yesterday.
    public let precipitationMinutesYesterday: Int?

    /// The API's calculated values, including the pressure trend
    public let calculated: CalculatedValues?

    /// Creates a summary from the values the API sends.
    ///
    /// - Parameters:
    ///   - lightningStrikeCountLastHour: Strikes in the last hour.
    ///   - lightningStrikeCountLastThreeHours: Strikes in the last three
    ///     hours.
    ///   - precipitationLastHour: Rain in the last hour, mm.
    ///   - lightningStrikeLastDistance: Distance to the last strike, km.
    ///   - lightningStrikeLastTime: When the last strike happened.
    ///   - precipitationYesterday: Yesterday's rain, mm.
    ///   - precipitationYesterdayFinal: Yesterday's rain after RainCheck, mm.
    ///   - precipitationAnalysisTypeYesterday: Which RainCheck correction was
    ///     applied.
    ///   - precipitationMinutesToday: Minutes of rain today.
    ///   - precipitationMinutesYesterday: Minutes of rain yesterday.
    ///   - calculated: The API's calculated values.
    public init(
        lightningStrikeCountLastHour: Int?,
        lightningStrikeCountLastThreeHours: Int?,
        precipitationLastHour: Double?,
        lightningStrikeLastDistance: Double?,
        lightningStrikeLastTime: Date?,
        precipitationYesterday: Double?,
        precipitationYesterdayFinal: Double?,
        precipitationAnalysisTypeYesterday: PrecipitationAnalysis?,
        precipitationMinutesToday: Int?,
        precipitationMinutesYesterday: Int?,
        calculated: CalculatedValues?,
    ) {
        self.lightningStrikeCountLastHour = lightningStrikeCountLastHour
        self.lightningStrikeCountLastThreeHours = lightningStrikeCountLastThreeHours
        self.precipitationLastHour = precipitationLastHour
        self.lightningStrikeLastDistance = lightningStrikeLastDistance
        self.lightningStrikeLastTime = lightningStrikeLastTime
        self.precipitationYesterday = precipitationYesterday
        self.precipitationYesterdayFinal = precipitationYesterdayFinal
        self.precipitationAnalysisTypeYesterday = precipitationAnalysisTypeYesterday
        self.precipitationMinutesToday = precipitationMinutesToday
        self.precipitationMinutesYesterday = precipitationMinutesYesterday
        self.calculated = calculated
    }
}
