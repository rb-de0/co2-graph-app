import SwiftUI
import Core
import Infra

@MainActor
final class RootViewModel: ObservableObject {
    
    @Published var repository: SensorDataRepository?
    
    nonisolated init() {}
    
    func initializeApp() async {
        let repository = await TimestreamSensorDataRepository()
        self.repository = repository
    }
}
