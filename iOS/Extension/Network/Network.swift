//
//  Network.swift
//  iOS
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case badResponse
    case unknown
}

class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request(url: URL, method: HTTPMethod, headers: [String: String]? = nil, body: Data? = nil) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        
        return session.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw NetworkError.badResponse
                }
                return output.data
            }
            .eraseToAnyPublisher()
    }
}

class NetworkViewModel {
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var data: Data?
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func validateToken(for url: URL, token: String) {
        let postData = ["token": token]
        let headers = ["Content-Type": "application/json"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        
        networkService.request(url: url, method: .post, headers: headers, body: jsonData)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in self?.data = $0 })
            .store(in: &cancellables)
    }
    
    func fetchData(from url: URL) {
        networkService.request(url: url, method: .get)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in self?.data = $0 })
            .store(in: &cancellables)
    }
}
