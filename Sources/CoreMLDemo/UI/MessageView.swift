import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    private var isIncoming: Bool {
        message.sender == .assistant || message.sender == .system
    }
    
    var body: some View {
        HStack {
            if !isIncoming { Spacer() }
            
            VStack(alignment: isIncoming ? .leading : .trailing) {
                Text(message.content)
                    .padding(Theme.defaultPadding)
                    .background(isIncoming ? Theme.messageBubbleIncoming : Theme.messageBubbleOutgoing)
                    .foregroundColor(isIncoming ? Theme.messageTextIncoming : Theme.messageTextOutgoing)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.bubbleCornerRadius))
                
                Text(message.formattedTimestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: Theme.maxMessageWidth, alignment: isIncoming ? .leading : .trailing)
            
            if isIncoming { Spacer() }
        }
    }
}