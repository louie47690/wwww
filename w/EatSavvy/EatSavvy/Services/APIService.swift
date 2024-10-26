import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.eatsavvy.com/v1" // Replace with your actual API endpoint
    
    private init() {}
    
    func fetchDeals() -> AnyPublisher<[Deal], APIError> {
        guard let url = URL(string: "\(baseURL)/deals") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Deal].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNearbyDeals(latitude: Double, longitude: Double) -> AnyPublisher<[Deal], APIError> {
        guard let url = URL(string: "\(baseURL)/deals/nearby?lat=\(latitude)&lon=\(longitude)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Deal].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
