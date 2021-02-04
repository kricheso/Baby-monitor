//
//  FormattedStringManager.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/1/21.
//

struct FormattedStringManager {
    
    static func getCurrentDate() -> String {
        let currentTime = Date()
        let month = format(currentTime, "LLLL")
        let day = format(currentTime, "d")
        let year = format(currentTime, "yyyy")
        return "\(month) \(day), \(year)"
    }
    
    static func getDuration(dateInterval: DateInterval) -> String {
        let duration = dateInterval.duration
        if duration >= 3600 { return ">1 hr" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let secondsString = "\(seconds) sec\(seconds == 1 ? "" : "s")"
        let minutesString = "\(minutes) min\(minutes == 1 ? "" : "s")"
        if minutes == 0 { return secondsString }
        return minutesString + " " + secondsString
    }
    
    static func getInterval(dateInterval: DateInterval) -> String {
        let start = dateInterval.start
        let end = dateInterval.end
        let startHour = format(start, "h")
        let startMinute = format(start, "mm")
        let startSecond = format(start, "ss")
        let startMarker = format(start, "a").lowercased()
        let endHour = format(end, "h")
        let endMinute = format(end, "mm")
        let endSecond = format(end, "ss")
        let endMarker = format(end, "a").lowercased()
        return "\(startHour):\(startMinute):\(startSecond) \(startMarker) - \(endHour):\(endMinute):\(endSecond) \(endMarker)"
    }

    private static func format(_ date: Date, _ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
}
