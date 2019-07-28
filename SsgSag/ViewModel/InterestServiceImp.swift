//
//  InterestServiceImp.swift
//  SsgSag
//
//  Created by admin on 18/05/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

class InterestServiceImp: InterestService {
    let requestMaker: RequestMakerProtocol
    let network: Network
    
    init(requestMaker: RequestMakerProtocol,
         network: Network) {
        self.requestMaker = requestMaker
        self.network = network
    }
    
    func requestInterestSubscribeDelete(_ interedIdx: Int,
                                        completionHandler: @escaping (DataResponse<BasicNetworkModel>) -> Void) {
        
        guard let token
            = UserDefaults.standard.object(forKey: TokenName.token) as? String,
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.subscribeAddOrDelete(interestIdx: interedIdx).getRequestURL),
            let request
            = requestMaker.makeRequest(url: url,
                                       method: .delete,
                                       header: ["Authorization": token,
                                                "Content-Type": "application/json"],
                                       body: nil) else {
            return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData
                        = try JSONDecoder().decode(BasicNetworkModel.self,
                                                   from: data)
                    
                    completionHandler(.success(decodedData))
                } catch let error {
                    completionHandler(.failed(error))
                    return
                }
            case .failure(let error):
                completionHandler(.failed(error))
                return
            }
        }
    }
    
    func requestInterestSubscribeAdd(_ interedIdx: Int,
                                     completionHandler: @escaping (DataResponse<BasicNetworkModel>) -> Void) {
        guard let token
            = UserDefaults.standard.object(forKey: TokenName.token) as? String,
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.subscribeAddOrDelete(interestIdx: interedIdx).getRequestURL),
            let request = requestMaker.makeRequest(url: url,
                                                   method: .post,
                                                   header: ["Authorization": token,
                                                            "Content-Type": "application/json"],
                                                   body: nil) else {
            return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData
                        = try JSONDecoder().decode(BasicNetworkModel.self,
                                                   from: data)
                    
                    completionHandler(.success(decodedData))
                } catch let error {
                    completionHandler(.failed(error))
                    return
                }
            case .failure(let error):
                completionHandler(.failed(error))
                return
            }
        }
    }
    
    func requestInterestSubscribe(completionHandler: @escaping (DataResponse<Subscribe>) -> Void) {
        
        guard let token
            = UserDefaults.standard.object(forKey: TokenName.token) as? String,
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.subscribeInterest.getRequestURL),
            let request
            = requestMaker.makeRequest(url: url,
                                       method: .get,
                                       header: ["Authorization": token,
                                                "Content-Type": "application/json"],
                                       body: nil) else {
            return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodeData
                        = try JSONDecoder().decode(Subscribe.self,
                                                   from: data)
                    
                    completionHandler(.success(decodeData))
                } catch let error {
                    completionHandler(.failed(error))
                    return
                }
            case .failure(let error):
                completionHandler(.failed(error))
                return
            }
        }
    }
}
