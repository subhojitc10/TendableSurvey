//
//  TendableAPI.swift
//  TendableTest
//
//  Created by Subhojit Chatterjee on 06/08/24.
//

import UIKit
import Alamofire

public class TendableAPI: NSObject {
    
    var session: Session
    
    init(session: Session = Session.default) {
        self.session = session
    }
    
    static let instance = TendableAPI()
    
    let baseUrl = "http://127.0.0.1:5001/"
    let serverErrorStr = "Unable to process your request currently. Please try again"
    
    func getServiceData<T>(url: String, method: Alamofire.HTTPMethod, parameters: [String: Any]?, encodingType: ParameterEncoding, headers: HTTPHeaders, decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, completion: @escaping (Result<T, ErrorCases>) ->()) where T: Codable {
        let absoluteUrl = baseUrl+url
        print("Request URL:::\(absoluteUrl)")
        print("Request Parameters:::\(parameters ?? [:])")
        if self.isConnectedToNetwork() {
            AF.request(absoluteUrl, method: method, parameters: parameters, encoding: encodingType, headers: headers).responseData(completionHandler: {response in
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Response Data:::: \(utf8Text)")
                }
                switch response.result {
                case .success(let res):
                    if let code = response.response?.statusCode {
                        switch code {
                        case 200...299:
                            //success
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = decodingStrategy
                                var parsedResponse = try decoder.decode(T.self, from: res)
                                    completion(.success(parsedResponse))
                            } catch DecodingError.keyNotFound(let key, let context) {
                                Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                                completion(.failure(.baseError(self.serverErrorStr)))
                            } catch DecodingError.valueNotFound(let type, let context) {
                                Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                                completion(.failure(.baseError(self.serverErrorStr)))
                            } catch DecodingError.typeMismatch(let type, let context) {
                                Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                                completion(.failure(.baseError(self.serverErrorStr)))
                            } catch DecodingError.dataCorrupted(let context) {
                                Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                                completion(.failure(.baseError(self.serverErrorStr)))
                            } catch let error as NSError {
                                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                                completion(.failure(.baseError(self.serverErrorStr)))
                            } catch let jsonError as NSError {
                                print("JSON decode failed: \(jsonError.localizedDescription)")
                                print(String(describing: jsonError))
                                completion(.failure(.baseError(self.serverErrorStr)))
                            }
                            
                        case 400...401:
                            //Unauthorized Specific Error Model based Handling
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = decodingStrategy
                                let errorResponse = try decoder.decode(ErrorModel.self, from: res)
                                completion(.failure(.forbidden(errorResponse.error ?? self.serverErrorStr)))
                            } catch _ as NSError {
                                completion(.failure(.baseError(self.serverErrorStr)))
                            }
                            
                        case 402...499:
                            //Unauthorized
                                
                            completion(.failure(.baseError(self.serverErrorStr)))
                                

                        default:
                            //random failure status handling
                            _ = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                print("Response Data:::: \(utf8Text)")
                                if let data = utf8Text.data(using: .utf8) {
                                    do {
                                        let jsonError = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                        //If the message comes as an array of strings, use the first string else the string.
                                        if let errMessages = jsonError?["message"] as? [String], !errMessages.isEmpty {
                                            completion(.failure(.baseError(self.serverErrorStr)))
                                        } else if let errMessage = jsonError?["message"] as? String, !errMessage.isEmpty {
                                            completion(.failure(.baseError(self.serverErrorStr)))
                                        } else {
                                            completion(.failure(.baseError(self.serverErrorStr)))
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(.baseError("Unable to access server")))
                }
            })
        } else {
            //No Internet
            completion(.failure(.noInternet))
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        if let reachability = Reachability() {
            let networkStatus = reachability.currentReachabilityStatus
            return (networkStatus != .notReachable)
        }

        return false
    }
    
    
}

public enum ErrorCases: Error {
    case noInternet
    case unAuthorized
    case badRequest
    case forbidden(String)
    case baseError(String)
}
