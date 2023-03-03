import SwiftUI
import Core

@MainActor
final class GraphViewModel: ObservableObject {
    
    @Published var graphData: [GraphSensorData] = []
    @Published var isLoading = false
    
    private let repository: SensorDataRepository
    private let dateFormatter: DateFormatter
    
    nonisolated init(repository: SensorDataRepository) {
        self.repository = repository
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.dateFormatter = dateFormatter
    }
    
    func fetchGraphData() async {
        do {
            isLoading = true
            let sensorData = try await repository.fetchSensorData()
            let task = Task.detached(priority: .background) { [dateFormatter] in
                return sensorData.map {
                    GraphSensorData(sensorData: $0, timeFormatted: dateFormatter.string(from: $0.time))
                }
            }
            let graphData = await task.value
            self.graphData = graphData
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    func refreshGraphData() {
        Task {
            await fetchGraphData()
        }
    }
}
