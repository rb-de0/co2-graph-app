public protocol SensorDataRepository {
    func fetchSensorData() async throws -> [SensorData]
}
