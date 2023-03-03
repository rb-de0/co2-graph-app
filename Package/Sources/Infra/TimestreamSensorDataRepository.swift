import Core
import AWSTimestreamQuery
import Foundation

public final class TimestreamSensorDataRepository: SensorDataRepository {
    
    private let clientResolver: TimestreamClientResolver
    private let dateFormatter: DateFormatter
    private let tableName: String
    
    public init() async {
        do {
            self.clientResolver = try await TimestreamClientResolver()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.gmt
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            self.dateFormatter = dateFormatter
            self.tableName = ProcessInfo.processInfo.environment["TABLE_NAME"] ?? ""
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func fetchSensorData() async throws -> [SensorData] {
        let client = try await clientResolver.resolveClient()
        let input = QueryInput(queryString: "SELECT * FROM \(tableName) ORDER BY time")
        let response = try await client.query(input: input)
        guard let timeIndex = response.columnInfo?.firstIndex(where: { $0.name == "time" }) else { return [] }
        guard let valueIndex = response.columnInfo?.firstIndex(where: { $0.name == "measure_value::bigint" }) else { return [] }
        let rows = response.rows ?? []
        return rows.compactMap { row -> SensorData? in
            guard let timeString = row.data?[timeIndex].scalarValue,
                  let value = row.data?[valueIndex].scalarValue.flatMap({ Int($0) }) else {
                return nil
            }
            guard let time = dateFormatter.date(from: timeString) else { return nil }
            return SensorData(time: time, value: value)
        }
    }
}
