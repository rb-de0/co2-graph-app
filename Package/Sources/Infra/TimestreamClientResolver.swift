import ClientRuntime
import AWSTimestreamQuery
import Foundation

actor TimestreamClientResolver {
    
    private let region: String
    private let describeEndpointsClient: TimestreamQueryClient
    private var clientCache: ClientCache?
    
    init() async throws {
        self.region = ProcessInfo.processInfo.environment["AWS_REGION"] ?? ""
        self.describeEndpointsClient = try await TimestreamQueryClient()
    }
    
    func resolveClient() async throws -> TimestreamQueryClient {
        if let clientCache = clientCache, clientCache.isValid() {
            return clientCache.client
        }
        let newClientCache = try await makeClient()
        if let clientCache = clientCache, clientCache.isValid() {
            return newClientCache.client
        }
        clientCache = newClientCache
        return newClientCache.client
    }
    
    private func makeClient() async throws -> ClientCache {
        let response = try await describeEndpointsClient.describeEndpoints(input: DescribeEndpointsInput())
        if let endpoint = response.endpoints?.first, let address = endpoint.address {
            let config = try TimestreamQueryClient.TimestreamQueryClientConfiguration(
                endpointResolver: FixedEndpointResolver(host: address),
                region: region
            )
            let client = TimestreamQueryClient(config: config)
            let cachedAt = Date()
            let cache = ClientCache(
                client: client,
                endpoint: .init(host: address, cachePeriodInMinutes: endpoint.cachePeriodInMinutes),
                cachedAt: cachedAt
            )
            return cache
        } else {
            throw ResolveError.describeEndpointsNotFound
        }
    }
}

extension TimestreamClientResolver {
    enum ResolveError: Error {
        case describeEndpointsNotFound
    }
}

extension TimestreamClientResolver {
    struct ClientCache {
        let client: TimestreamQueryClient
        let endpoint: EndpointCache
        let cachedAt: Date
        
        func isValid(now: Date = Date()) -> Bool {
            return now.timeIntervalSince(cachedAt) <= TimeInterval(endpoint.cachePeriodInMinutes * 60)
        }
    }
    
    struct EndpointCache {
        let host: String
        let cachePeriodInMinutes: Int
    }
}

private final class FixedEndpointResolver: EndpointResolver {

    private let host: String
    
    init(host: String) {
        self.host = host
    }
    
    func resolve(params: EndpointParams) throws -> Endpoint {
        return Endpoint(host: host)
    }
}
