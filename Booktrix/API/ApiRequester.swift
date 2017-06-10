//
//  ApiRequester.swift
//  Booktrix
//
//  Created by Impresyjna on 17.05.2017.
//  Copyright © 2017 Impresyjna. All rights reserved.
//

import Alamofire
import JSONCodable

enum HTTPError: Int, DisplayableError {
    case badRequest = 400
    case notAuthorized = 401
    case forbidden = 403
    case notFound = 404
    case conflicted = 409
    case unprocessable = 422
    case serverError = 500
    case unknown
    
    var errorMessage: String {
        switch self {
        case .badRequest:
            return LocalizedString.badRequest
        case .notAuthorized:
            return LocalizedString.notAuthorized
        case .forbidden:
            return LocalizedString.forbidden
        case .notFound:
            return LocalizedString.notFound
        case .unprocessable:
            return LocalizedString.unprocessable
        case .conflicted:
            return LocalizedString.conflicted
        case .serverError:
            return LocalizedString.serverError
        case .unknown:
            return LocalizedString.unknown
        }
    }
    
    init(code: Int?) {
        self = code.flatMap(HTTPError.init(rawValue:)) ?? .unknown
    }
}

enum ApiResponse<T> {
    case success(T)
    case failure(HTTPError)
}

struct Adapter: RequestAdapter {
    fileprivate let storage: KeychainStorage
    
    init(keychain: KeychainStorage) {
        self.storage = keychain
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var mutable = urlRequest
        
        if let token = storage.getUser()?.token {
            mutable.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        return mutable
    }
}

final class ApiRequester {
    fileprivate let manager: SessionManager
    
    init(manager: SessionManager = .default) {
        self.manager = manager
        manager.adapter = Adapter(keychain: .init())
    }
    
    func request<T:JSONDecodable>(request: Request, params: RequestParams? = nil, encoding: ParameterEncoding = JSONEncoding(), completion: @escaping (ApiResponse<T>) -> ()) {
        manager.request(request.url, method: request.method, parameters: params?.params, encoding: encoding, headers: nil)
            .validate(statusCode: 200...422)
            .responseJSON { result in
                guard let object = result.value
                    .flatMap({ $0 as? [String: Any] })
                    .flatMap({ try? T(object: $0) })
                    else {
                        completion(.failure(HTTPError(code: result.response?.statusCode)))
                        return
                }
                
                completion(.success(object))
        }
    }
    
    func request<T:JSONDecodable>(request: Request, params: RequestParams? = nil, completion: @escaping (ApiResponse<[T]>) -> ()) {
        manager.request(request.url, method: request.method, parameters: params?.params, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseJSON { result in
                guard let objects = result.value
                    .flatMap({ $0 as? [[String: Any]] })
                    .flatMap({ try? [T](JSONArray: $0) })
                    else {
                        completion(.failure(HTTPError(code: result.response?.statusCode)))
                        return
                }
                
                completion(.success(objects))
        }
    }
    
    func request(request: Request, params: RequestParams? = nil, completion: @escaping (ApiResponse<Void>) -> ()) {
        manager.request(request.url, method: request.method, parameters: params?.params, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseJSON { result in
                
                if let _ = result.error {
                    completion(.failure(HTTPError(code: result.response?.statusCode)))
                    return
                }
                
                completion(.success(()))
        }
    }
}
