//
//  AncileStudyServerClient.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 6/22/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

//import UIKit
import Alamofire

open class AncileStudyServerClient: NSObject {
    
    public struct SignInResponse {
        public let authToken: String
    }
    
    let baseURL: String
    let dispatchQueue: DispatchQueue?
    
    public init(baseURL: String, dispatchQueue: DispatchQueue? = nil) {
        self.baseURL = baseURL
        self.dispatchQueue = dispatchQueue
        super.init()
    }

    var authURL: URL? {
        return URL(string: "\(self.baseURL)/accounts/google/login")
    }
    
    open func processAuthResponse(isRefresh: Bool, completion: @escaping ((SignInResponse?, Error?) -> ())) -> ((DataResponse<Any>) -> ()) {
        
        return { jsonResponse in
            
            debugPrint(jsonResponse)
            //check for lower level errors
            if let error = jsonResponse.result.error as? NSError {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, AncileStudyServerClientError.unreachableError(underlyingError: error))
                    return
                }
                else {
                    completion(nil, AncileStudyServerClientError.otherError(underlyingError: error))
                    return
                }
            }
            
            //check for our errors
            //credentialsFailure
            guard let response = jsonResponse.response else {
                completion(nil, AncileStudyServerClientError.malformedResponse(responseBody: jsonResponse))
                return
            }
            
            if let response = jsonResponse.response,
                response.statusCode == 502 {
                debugPrint(jsonResponse)
                completion(nil, AncileStudyServerClientError.badGatewayError)
                return
            }
            
//            if response.statusCode != 200 {
//                
//                guard jsonResponse.result.isSuccess,
//                    let json = jsonResponse.result.value as? [String: Any],
//                    let error = json["error"] as? String,
//                    let errorDescription = json["error_description"] as? String else {
//                        completion(nil, OMHClientError.malformedResponse(responseBody: jsonResponse.result.value))
//                        return
//                }
//                
//                if error == "invalid_grant" {
//                    if isRefresh {
//                        completion(nil, OMHClientError.invalidRefreshToken)
//                    }
//                    else {
//                        completion(nil, OMHClientError.credentialsFailure(descrition: errorDescription))
//                    }
//                    return
//                }
//                else {
//                    completion(nil, OMHClientError.serverError(error: error, errorDescription: errorDescription))
//                    return
//                }
//                
//            }
//            
            //check for malformed body
            guard jsonResponse.result.isSuccess,
                let json = jsonResponse.result.value as? [String: Any],
                let authToken = json["auth_token"] as? String else {
                    completion(nil, AncileStudyServerClientError.malformedResponse(responseBody: jsonResponse.result.value))
                    return
            }

            //fill in with actual server errors
            let signInResponse = SignInResponse(authToken: authToken)

            completion(signInResponse, nil)
            
        }
        
    }
    
    open func signIn(code: String, completion: @escaping ((SignInResponse?, Error?) -> ())) {
        
        let urlString = "\(self.baseURL)/verify"
        let parameters = [
            "code": code
        ]
        
//        let headers = ["Authorization": "Basic \(self.basicAuthString)"]
        let headers: [String: String] = [:]
        
        let request = Alamofire.request(
            urlString,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers)
        
        request.responseJSON(queue: self.dispatchQueue, completionHandler: self.processAuthResponse(isRefresh: false, completion: completion))
        
    }

    open func getCoreLink(authToken: String, completion: @escaping ((String?, Error?) -> ())) {
        
        let urlString = "\(self.baseURL)/temporary_core_link"
        let headers = ["Authorization": "Token \(authToken)"]
        
        let request = Alamofire.request(
            urlString,
            method: .get,
            encoding: JSONEncoding.default,
            headers: headers)
        
        request.responseJSON(queue: self.dispatchQueue, completionHandler: { jsonResponse in
            
            
            debugPrint(jsonResponse)
            //check for lower level errors
            if let error = jsonResponse.result.error as? NSError {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, AncileStudyServerClientError.unreachableError(underlyingError: error))
                    return
                }
                else {
                    completion(nil, AncileStudyServerClientError.otherError(underlyingError: error))
                    return
                }
            }
            
            //check for our errors
            //credentialsFailure
            guard let response = jsonResponse.response else {
                completion(nil, AncileStudyServerClientError.malformedResponse(responseBody: jsonResponse))
                return
            }
            
            if let response = jsonResponse.response,
                response.statusCode == 502 {
                debugPrint(jsonResponse)
                completion(nil, AncileStudyServerClientError.badGatewayError)
                return
            }
            
            //check for malformed body
            guard jsonResponse.result.isSuccess,
                let json = jsonResponse.result.value as? [String: Any],
                let url = json["core_auth_url"] as? String else {
                    completion(nil, AncileStudyServerClientError.malformedResponse(responseBody: jsonResponse.result.value))
                    return
            }
            
            //fill in with actual server errors
            
            completion(url, nil)
            
            
        })
        
    }
    
//    open func refreshAccessToken(refreshToken: String, completion: @escaping ((SignInResponse?, Error?) -> ()))  {
//        let urlString = "\(self.baseURL)/oauth/token"
//        let parameters = [
//            "grant_type": "refresh_token",
//            "refresh_token": refreshToken]
//        
////        let headers = ["Authorization": "Basic \(self.basicAuthString)"]
//        let headers: [String: String] = [:]
//        
//        let request = Alamofire.request(
//            urlString,
//            method: .post,
//            parameters: parameters,
//            headers: headers)
//        
//        request.responseJSON(queue: self.dispatchQueue, completionHandler: self.processAuthResponse(isRefresh: true, completion: completion))
//        
//    }
    
    open func postConsent(token: String, completion: @escaping ((Bool, Error?) -> ())) {
        
    }
    
    open func withdrawConsent(token: String, completion: @escaping ((Bool, Error?) -> ())) {
        
    }
    
}
