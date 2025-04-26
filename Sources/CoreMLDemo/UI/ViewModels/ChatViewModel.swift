import SwiftUI
import OpenAI

@MainActor
class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    
    private let conversationManager: ConversationManager
    private let openAI: OpenAIProtocol
    private var currentSessionId: String?
    
    init() {
        self.conversationManager = ConversationManager(telemetry: TelemetryManager())
        
        // Initialize OpenAI client
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        self.openAI = OpenAI(apiToken: apiKey)
        
        setupSession()
    }
    
    private func setupSession() {
        currentSessionId = conversationManager.createSession()
        // Add welcome message
        messages.append(ChatMessage(
            content: "Hi! I'm your AI assistant. How can I help you today?",
            sender: .assistant
        ))
    }
    
    func sendMessage(_ content: String) async {
        guard let sessionId = currentSessionId else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: content, sender: .user)
        messages.append(userMessage)
        
        do {
            // Process message with conversation manager
            _ = try await conversationManager.processMessage(content, sessionId: sessionId)
            
            // Create chat messages array
            let chatMessages: [ChatQuery.ChatCompletionMessageParam] = [
                .init(role: .system, content: "You are a helpful AI assistant that provides concise and accurate responses.")!,
                .init(role: .user, content: content)!
            ]
            
            // Create chat query
            let query = ChatQuery(
                messages: chatMessages,
                model: .gpt4
            )
            
            let result = try await openAI.chats(query: query)
            if let aiResponse = result.choices.first?.message.content {
                let assistantMessage = ChatMessage(content: aiResponse, sender: .assistant)
                messages.append(assistantMessage)
            }
            
        } catch {
            messages.append(ChatMessage(
                content: "Sorry, I encountered an error processing your message.",
                sender: .system
            ))
        }
    }
    
    func clearChat() {
        messages.removeAll()
        setupSession()
    }
}