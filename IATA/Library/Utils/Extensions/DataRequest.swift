import PromiseKit
import Alamofire

extension DataRequest {
    
    internal func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<Any> {
        return Promise { fulfill, reject in
            responseJSON(queue: nil, options: options, completionHandler: { response in
                if response.response?.statusCode == 401 {
                    reject(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)))
                } else if let value = response.result.value {
                    fulfill(value)
                } else {
                    reject(response.result.error ?? IATAOpError.serverError(message: ""))
                }
            })
        }
    }
    
    internal func responseData() -> Promise<Data> {
        return Promise { fulfill, reject in
            responseData(queue: nil) { response in
                if response.response?.statusCode == 401 {
                    reject(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)))
                } else if let value = response.result.value {
                    fulfill(value)
                } else {
                    reject(response.result.error ?? IATAOpError.serverError(message: ""))
                }
            }
        }
    }
    
    internal func responseString() -> Promise<String> {
        return Promise { fulfill, reject in
            responseString(queue: nil) { response in
                if response.response?.statusCode == 401 {
                    reject(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)))
                } else if let value = response.result.value {
                    fulfill(value)
                } else {
                    reject(response.result.error ?? IATAOpError.serverError(message: ""))
                }
            }
        }
    }
}
