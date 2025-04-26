import Foundation

/// Manages telemetry and observability for the system
class TelemetryManager {
    private var events: [(String, [String: String], Date)] = []
    private var errors: [(String, Error, Date)] = []
    
    func logEvent(_ name: String, metadata: [String: String] = [:]) {
        events.append((name, metadata, Date()))
        print("[Event] \(name) - \(metadata)")
    }
    
    func logError(_ message: String, _ error: Error) {
        errors.append((message, error, Date()))
        print("[Error] \(message): \(error)")
    }
    
    func getMetrics() -> TelemetryMetrics {
        let totalEvents = events.count
        let totalErrors = errors.count
        let eventTypes = Dictionary(grouping: events, by: { $0.0 })
            .mapValues { $0.count }
        
        return TelemetryMetrics(
            totalEvents: totalEvents,
            totalErrors: totalErrors,
            eventCounts: eventTypes
        )
    }
}

struct TelemetryMetrics {
    let totalEvents: Int
    let totalErrors: Int
    let eventCounts: [String: Int]
}