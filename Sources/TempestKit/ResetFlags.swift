//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The reasons a hub says it reset, from its status broadcast.
///
/// The API sends `reset_flags` as a comma-separated string, like `BOR,PIN`.
/// A flag we don't know is ignored here; `HubStatus` keeps the raw string.
public struct ResetFlags: OptionSet, Hashable, Sendable {

    /// The bits the API sent.
    public let rawValue: Int

    /// Creates a set from the bits the API sent.
    ///
    /// - Parameter rawValue: The bit field.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The supply voltage dropped.
    public static let brownout = ResetFlags(rawValue: 1 << 0)
    /// The reset pin was pulled.
    public static let pin = ResetFlags(rawValue: 1 << 1)
    /// Power was applied.
    public static let power = ResetFlags(rawValue: 1 << 2)
    /// Software asked for a reset.
    public static let software = ResetFlags(rawValue: 1 << 3)
    /// The watchdog fired.
    public static let watchdog = ResetFlags(rawValue: 1 << 4)
    /// The window watchdog fired.
    public static let windowWatchdog = ResetFlags(rawValue: 1 << 5)
    /// The hub hit its low-power cutoff.
    public static let lowPower = ResetFlags(rawValue: 1 << 6)
    /// The processor hit a hard fault.
    public static let hardFault = ResetFlags(rawValue: 1 << 7)

    /// Reads the API's comma-separated names.
    ///
    /// - Parameter names: The string from `reset_flags`, like `BOR,PIN,POR`.
    public init(names: String) {
        var flags: ResetFlags = []
        for part in names.split(separator: ",") {
            switch String(part).trimmingCharacters(in: .whitespaces).uppercased() {
            case "BOR": flags.insert(.brownout)
            case "PIN": flags.insert(.pin)
            case "POR": flags.insert(.power)
            case "SFT": flags.insert(.software)
            case "WDG": flags.insert(.watchdog)
            case "WWD": flags.insert(.windowWatchdog)
            case "LPW": flags.insert(.lowPower)
            case "HRDFLT": flags.insert(.hardFault)
            default: break
            }
        }
        self = flags
    }
}
