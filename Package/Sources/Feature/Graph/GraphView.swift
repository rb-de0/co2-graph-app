import SwiftUI
import Charts
import Core

struct GraphView: View {
    
    @StateObject var viewModel: GraphViewModel
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                if viewModel.graphData.count > 0 {
                    Chart {
                        ForEach(viewModel.graphData) { data in
                            AreaMark(
                                x: .value("DateTime", data.time),
                                y: .value("Value", data.value)
                            )
                            .opacity(0.5)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 1)) { data in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .wide)).day().month(),
                                           orientation: .vertical)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartYScale(domain: 0...1200)
                    .chartXScale(domain: .automatic(reversed: true))
                    .frame(width: CGFloat(viewModel.graphData.count) * 40)
                    .padding()
                    .foregroundColor(Color("AccentColor", bundle: .module))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            ZStack {
                Button(action: {
                    viewModel.refreshGraphData()
                }, label: {
                    Image(systemName: "goforward")
                })
                .disabled(viewModel.isLoading)
                .frame(width: 64, height: 64)
                .background(Color("AccentColor", bundle: .module))
                .foregroundColor(Color("ForegroundColor", bundle: .module))
                .cornerRadius(32)
                .compositingGroup()
                .shadow(radius: 2, x: 3, y: 3)
            }
            .padding(.bottom, 24)
            .padding(.trailing, 24)
        }
        .task {
            await viewModel.fetchGraphData()
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(viewModel: .init(repository: PreviewSensorDataRepository()))
    }
}

private final class PreviewSensorDataRepository: SensorDataRepository {
    func fetchSensorData() async throws -> [SensorData] {
        let now = Date()
        return (0...200).map { i in
            let adding = Array(-100...100).randomElement()!
            return SensorData(time: now.addingTimeInterval(TimeInterval(i * 600)),
                              value: 700 + adding)
        }
    }
}
