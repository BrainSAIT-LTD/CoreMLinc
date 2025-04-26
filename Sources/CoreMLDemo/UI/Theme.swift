import SwiftUI

enum Theme {
    static let chatBackground = Color(nsColor: .windowBackgroundColor)
    static let messageBubbleIncoming = Color(nsColor: .controlBackgroundColor)
    static let messageBubbleOutgoing = Color.blue
    static let messageTextIncoming = Color(nsColor: .labelColor)
    static let messageTextOutgoing = Color.white
    
    static let defaultPadding: CGFloat = 12
    static let bubbleCornerRadius: CGFloat = 16
    static let maxMessageWidth: CGFloat = 280
}

#if canImport(UIKit)
import UIKit
extension Color {
    init(uiColor: UIColor) {
        self.init(UIColor(cgColor: uiColor.cgColor))
    }
}
#else
import AppKit
extension Color {
    init(nsColor: NSColor) {
        self.init(NSColor(cgColor: nsColor.cgColor)!)
    }
}
#endif