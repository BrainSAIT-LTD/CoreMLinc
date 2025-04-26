import Foundation

struct ConversationMessage {
    let id: UUID
    let content: String
    let timestamp: Date
    let metadata: [String: String]
}

struct ConversationSession {
    let id: String
    var messages: [ConversationMessage]
    let startTime: Date
    var lastActivityTime: Date
}

struct ConversationResponse {
    let message: ConversationMessage
    let sessionId: String
}

enum ConversationError: Error {
    case invalidSession
    case messageProcessingFailed
}

class ConversationManager {
    private var sessions: [String: ConversationSession] = [:]
    private let telemetry: TelemetryManager
    
    init(telemetry: TelemetryManager) {
        self.telemetry = telemetry
    }
    
    func createSession() -> String {
        let sessionId = UUID().uuidString
        sessions[sessionId] = ConversationSession(
            id: sessionId,
            messages: [],
            startTime: Date(),
            lastActivityTime: Date()
        )
        
        telemetry.logEvent("conversation_session_created", metadata: ["session_id": sessionId])
        return sessionId
    }
    
    func processMessage(_ message: String, sessionId: String) async throws -> ConversationResponse {
        guard let session = sessions[sessionId] else {
            throw ConversationError.invalidSession
        }
        
        let newMessage = ConversationMessage(
            id: UUID(),
            content: message,
            timestamp: Date(),
            metadata: [:]
        )
        
        // Update session
        var updatedSession = session
        updatedSession.messages.append(newMessage)
        updatedSession.lastActivityTime = Date()
        sessions[sessionId] = updatedSession
        
        telemetry.logEvent("message_processed", metadata: [
            "session_id": sessionId,
            "message_id": newMessage.id.uuidString
        ])
        
        return ConversationResponse(
            message: newMessage,
            sessionId: sessionId
        )
    }
    
    func getSessionHistory(_ sessionId: String) throws -> [ConversationMessage] {
        guard let session = sessions[sessionId] else {
            throw ConversationError.invalidSession
        }
        return session.messages
    }
    
    func cleanupInactiveSessions(olderThan timeInterval: TimeInterval = 3600) {
        let cutoffDate = Date().addingTimeInterval(-timeInterval)
        sessions = sessions.filter { $0.value.lastActivityTime > cutoffDate }
        
        telemetry.logEvent("inactive_sessions_cleaned")
    }
}