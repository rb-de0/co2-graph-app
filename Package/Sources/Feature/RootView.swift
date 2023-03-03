import SwiftUI

public struct RootView: View {
    
    @StateObject private var viewModel = RootViewModel()
    
    public init() {}
    
    public var body: some View {
        Group {
            if let repository = viewModel.repository {
                GraphView(viewModel: .init(repository: repository))
            } else {
                Text("Initializing...")
            }
        }
        .task {
            await viewModel.initializeApp()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
