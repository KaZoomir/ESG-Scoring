//
//  NetworkService.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case unauthorized
    case noInternet
    
    var message: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .decodingError: return "Failed to decode data"
        case .serverError(let msg): return msg
        case .unauthorized: return "Unauthorized access"
        case .noInternet: return "No internet connection"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    // Configure base URL when backend is ready
    private let baseURL = "https://api.esg-kbtu.com/v1" // Replace with actual URL
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Generic Request Method
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<T, NetworkError> {
        
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                case 400...499:
                    throw NetworkError.serverError("Client error: \(httpResponse.statusCode)")
                case 500...599:
                    throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
                default:
                    throw NetworkError.invalidResponse
                }
            }
            .decode(type: T.self, decoder: JSONDecoder.iso8601)
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return .decodingError
                }
                return error as? NetworkError ?? .serverError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Mode (for development without backend)
    
    var useMockData = true // Set to false when backend is ready
    
    func mockRequest<T: Decodable>(
        delay: TimeInterval = 1.0,
        result: Result<T, NetworkError>
    ) -> AnyPublisher<T, NetworkError> {
        return Future<T, NetworkError> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Extensions

extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {
    static var iso8601: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

// MARK: - Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct MessageResponse: Codable {
    let message: String
}
