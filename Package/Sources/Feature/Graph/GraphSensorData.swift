import Core
import Foundation

public struct GraphSensorData: Identifiable {
    public var id: Date { time }
    public let timeFormatted: String
    public let time: Date
    public let value: Int
    
    public init(sensorData: SensorData, timeFormatted: String) {
        self.time = sensorData.time
        self.value = sensorData.value
        self.timeFormatted = timeFormatted
    }
}
