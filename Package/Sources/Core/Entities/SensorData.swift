import Foundation

public struct SensorData: Identifiable {
    public var id: Date { time }
    public let time: Date
    public let value: Int
    
    public init(time: Date, value: Int) {
        self.time = time
        self.value = value
    }
}
