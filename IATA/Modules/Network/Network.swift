import PromiseKit
import Alamofire
import ObjectMapper

class Network {
    
    public static var shared = Network()
    
    private init() {}
    
    public var serverBaseURL: String {
        return NetworkConfig.shared.baseServerURL
    }
    
    private let serverErrorExtractor = ServerErrorExtractor()
    
    private let syncQueue: DispatchQueue = DispatchQueue(label: "")
    private var refreshTokenPromise: Promise<Void>?
    
    private let manager: SessionManager = {
        var serverTrustPolicies = [String: ServerTrustPolicy]()
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration,
                              serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    
    // swiftlint:disable function_body_length
    private func request<TResult>(path: String, method: HTTPMethod, params: [String: Any],
                                  encoding: ParameterEncoding = URLEncoding.default,
                                  response: @escaping (DataRequest) -> Promise<TResult>) -> Promise<TResult> {
        let createRequest = {
            return response(self.manager.request(NetworkUtil.makeFullUrl(baseUrl: self.serverBaseURL, path: path),
                                                 method: method,
                                                 parameters: params,
                                                 encoding: encoding,
                                                 headers: self.makeHeaders()))
        }
        
        return Promise<TResult>(resolvers: { success, failed in
            self.syncQueue.async {
                if let refreshTokenPromise = self.refreshTokenPromise {
                    self.request(initialRequest: refreshTokenPromise, createRequest: createRequest,
                                 success: success, failed: failed)
                } else {
                    Promise().then(execute: { () -> Promise<TResult> in
                        return createRequest()
                    }).then(execute: { (result: TResult) -> Void in
                        success(result)
                    }).catch(execute: { (error: Error) -> Void in
                        self.handleRequestError(error: error,
                                                createRequest: createRequest,
                                                success: success,
                                                failed: failed)
                    })
                }
            }
        })
    }
    
    private func request<TResult>(initialRequest: Promise<Void>,
                                  createRequest: @escaping () -> Promise<TResult>,
                                  success: @escaping (TResult) -> Void,
                                  failed: @escaping (Error) -> Void) {
        initialRequest
            .then(execute: { () -> Promise<TResult> in
                createRequest()
            }).then(execute: { (result: TResult) -> Void in
                success(result)
            }).catch(execute: { (error: Error) -> Void in
                failed(error)
            })
    }

    
    private func handleRequestError<TResult>(error: Error,
                                             createRequest: @escaping (() -> Promise<TResult>),
                                             success: @escaping (TResult) -> Void,
                                             failed: @escaping (Error) -> Void) {
        guard let afError = error as? AFError,
            case .responseValidationFailed(reason: .unacceptableStatusCode(code: let code)) = afError,
            code == 401 else {
                failed(error)
                return

        }
        
        request(initialRequest: self.refreshTokenRequest(), createRequest: createRequest,
                success: success, failed: failed)
    }
    
    //swiftlint:disable function_body_length
    internal func refreshTokenRequest() -> Promise<Void> {
        return Promise<Void> { (success, failed) in
            self.syncQueue.async {
            }
        }
    }
    
    private func makeHeaders() -> [String: String]? {
        if let accessToken = CredentialManager.shared.getAccessToken() {
            return ["Authorization": "Bearer " + accessToken]
        }
        return nil
    }
    
    private func saveTokenObject(_ tokenObject: TokenObject) {
        if CredentialManager.shared.tokenObject == nil {
            CredentialManager.shared.saveTokenObject(tokenObject)
        } else {
            CredentialManager.shared.tokenObject = tokenObject
        }
    }
    
    public func post<ResultType: BaseMappable>(path: String,
                                               params: [String: Any],
                                               encodingType: EncodingType = .url) -> Promise<ResultType> {
        return request(path: path, method: .post, params: params, encoding: encodingType.parameters)
    }
    
    public func post<ResultType: BaseMappable>(path: String, object: Mappable) -> Promise<ResultType> {
        return request(path: path, method: .post, params: object.toJSON(), encoding: JSONEncoding.default)
    }
    
    public func post(path: String, object: BaseMappable) -> Promise<Void> {
        return request(path: path, method: .post, params: object.toJSON(), encoding: JSONEncoding.default)
    }
    
    public func post<ResultType: BaseMappable>(path: String, objects: [Mappable]) -> Promise<ResultType> {
        let params = objects.map({ $0.toJSON() })
        return request(path: path, method: .post, params: params.asParameters(), encoding: ArrayEncoding())
    }
    
    public func post(path: String, objects: [BaseMappable]) -> Promise<Void> {
        let params = objects.map({ $0.toJSON() })
        return request(path: path, method: .post, params: params.asParameters(), encoding: ArrayEncoding())
    }
    
    public func post(path: String, params: [String: Any]) -> Promise<Void> {
        return request(path: path, method: .post, params: params, encoding: URLEncoding.httpBody)
    }
    
    public func post<ResultType: BaseMappable>(path: String, objects: [Mappable],
                                               arrayJSONPropertyName: String) -> Promise<ResultType> {
        let params = objects.map({ $0.toJSON() })
        return request(path: path, method: .post,
                       params: [arrayJSONPropertyName: params],
                       encoding: JSONEncoding.default)
    }
    
    public func post(path: String, objects: [Mappable], arrayJSONPropertyName: String) -> Promise<Void> {
        let params = objects.map({ $0.toJSON() })
        return request(path: path, method: .post,
                       params: [arrayJSONPropertyName: params],
                       encoding: JSONEncoding.default)
    }
    
    public func post(path: String, params: [String: Any]) -> Promise<String> {
        return request(path: path, method: .post, params: params)
    }
    
    public func get<ResultType: BaseMappable>(path: String, params: [String: Any]) -> Promise<ResultType> {
        return request(path: path, method: .get, params: params, encoding: ArrayEncoding())
    }
    
    public func get(path: String, params: [String: Any]) -> Promise<String> {
        return request(path: path, method: .get, params: params, encoding: BrasketLessGetEncoding())
    }
    
   
    public func get(path: String, params: [String: Any]) -> Promise<Data> {
        return request(path: path, method: .get, params: params)
    }
    
    public func put(path: String, object: BaseMappable) -> Promise<Void> {
        return request(path: path, method: .put, params: object.toJSON(), encoding: JSONEncoding.default)
    }
    
    public func delete(path: String) -> Promise<Void> {
        return request(path: path, method: .delete, params: [:])
    }
    
    private func request(path: String,
                         method: HTTPMethod,
                         params: [String: Any],
                         encoding: ParameterEncoding = URLEncoding.default) -> Promise<Void> {
        return request(path: path, method: method, params: params, encoding: encoding)
            .then { (_: String) -> Void in
        }
    }
    
    private func request<ResultType: BaseMappable>(path: String,
                                                   method: HTTPMethod,
                                                   params: [String: Any],
                                                   encoding: ParameterEncoding = URLEncoding.default)
        -> Promise<ResultType> {
            return request(path: path,
                           method: method,
                           params: params,
                           encoding: encoding,
                           response: { (request: DataRequest) -> Promise<Any> in
                            return request.responseJSON()
            }).then(execute: { (json) -> ResultType in
                return try self.mapJSON(json: json)
            })
    }
    
    private func request(path: String, method: HTTPMethod, params: [String: Any],
                         encoding: ParameterEncoding = URLEncoding.default) -> Promise<Data> {
        return request(path: path,
                       method: method,
                       params: params,
                       encoding: encoding,
                       response: { (request: DataRequest) -> Promise<Data> in
                        return request.validate().responseData()
        }).then { (responseData: Data) -> Data in
            return responseData
        }
    }
    
    private func request(path: String, method: HTTPMethod, params: [String: Any],
                         encoding: ParameterEncoding = URLEncoding.default) -> Promise<String> {
        return request(path: path,
                       method: method,
                       params: params,
                       encoding: encoding,
                       response: { (request: DataRequest) -> Promise<String> in
                        return request.responseString()
        }).then { (responseString: String) -> String in
            if let error = self.serverErrorExtractor.extract(from: responseString) {
                throw error
            }
            return responseString
        }
    }
    
    private func mapJSON<ResultType: BaseMappable>(json: Any) throws -> ResultType {
        if let error = self.serverErrorExtractor.extract(from: json) {
            throw error
        }
        if let jsonDict = json as? [String: Any] {
           
            if let result = ResultType(JSON: jsonDict) {
                return result
            } else {
                throw IATAOpError.serverError(message: "Cannot parse server response")
            }
        } else {
            if let empty = ResultType(JSON: [String: Any]()) {
                return empty
            } else {
                throw IATAOpError.serverError(message: "Cannot create empty response")
            }
        }
    }
}
