//
//  CryIntervals.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/3/21.
//

import Foundation

/// A wrapper class to store cry intervals.
class CryIntervals {
    
    private(set) var data: [DateInterval] = []
    let confidenceThreshold: Double
    let maximumCryGap: TimeInterval
    let minimumCryDuration: TimeInterval
    private var purgatory: DateInterval? // Stores an interval that is too short to be considered as data
    
    /// Dictates three things:
    /// 1) The confidence percent required to be consider as a cry
    /// 2) The maximum cry gap allowed in seconds.
    /// 3) The minimum number of seconds that a cry event can exist.
    public init(confidenceThreshold: Double, maximumCryGap: TimeInterval, minimumCryDuration: TimeInterval) {
        self.confidenceThreshold = confidenceThreshold
        self.maximumCryGap = maximumCryGap
        self.minimumCryDuration = minimumCryDuration
    }
    
    /// Records confidence percentages and decides whether to add, modify, or discard it in the master data set.
    /// - Returns: The type of modification performed on the data.
    @discardableResult
    func recordData(confidence: Double) -> ModificationType {
        guard confidence >= confidenceThreshold else { return .noChange }
        if purgatory == nil && data.isEmpty {
            purgatory = DateInterval(start: Date(), end: Date())
            return .noChange
        }
        let lastRecordedTime = max(purgatory?.end ?? Date.distantPast, data.last?.end ?? Date.distantPast)
        let timeGap = DateInterval(start: lastRecordedTime, end: Date()).duration
        if timeGap > maximumCryGap {
            self.purgatory = DateInterval(start: Date(), end: Date())
            return .noChange
        }
        if let purgatory = purgatory {
            let updatedInterval = DateInterval(start: purgatory.start, end: Date())
            if updatedInterval.duration >= minimumCryDuration {
                self.purgatory = nil
                data.append(updatedInterval)
                return .createdNewEntry
            } else {
                self.purgatory = updatedInterval
                return .noChange
            }
        }
        if let lastInterval = data.last {
            data.removeLast()
            data.append(DateInterval(start: lastInterval.start, end: Date()))
            return .modifiedExistingEntry
        }
        return .noChange
    }
    
}
