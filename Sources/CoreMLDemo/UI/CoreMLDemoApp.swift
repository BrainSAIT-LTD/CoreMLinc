import SwiftUI

#if ENABLE_GUI
struct CoreMLDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView()
        }
    }
}
#endif