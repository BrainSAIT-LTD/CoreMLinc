import Foundation

enum MessageSender: Equatable {
    case user
    case assistant
    case system
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    let sender: MessageSender
    let metadata: [String: String]
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    init(id: UUID = UUID(), content: String, sender: MessageSender, metadata: [String: String] = [:]) {
        self.id = id
        self.content = content
        self.timestamp = Date()
        self.sender = sender
        self.metadata = metadata
    }
    
    init(from conversationMessage: ConversationMessage, sender: MessageSender) {
        self.id = conversationMessage.id
        self.content = conversationMessage.content
        self.timestamp = conversationMessage.timestamp
        self.sender = sender
        self.metadata = conversationMessage.metadata
    }
}