import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: Theme.defaultPadding) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            Divider()
            
            HStack(spacing: Theme.defaultPadding) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .submitLabel(.send)
                    .onSubmit(sendMessage)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .background(Theme.chatBackground)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        Task {
            await viewModel.sendMessage(messageText)
            messageText = ""
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessageId = viewModel.messages.last?.id else { return }
        withAnimation {
            proxy.scrollTo(lastMessageId, anchor: .bottom)
        }
    }
}