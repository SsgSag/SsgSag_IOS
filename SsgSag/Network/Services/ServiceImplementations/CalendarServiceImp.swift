//
//  CalendarServiceImp.swift
//  SsgSag
//
//  Created by admin on 23/04/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class CalendarServiceImp: CalendarService {
    
    let requestMaker: RequestMakerProtocol
    let network: Network
    
    init(requestMaker: RequestMakerProtocol,
         network: Network) {
        self.requestMaker = requestMaker
        self.network = network
    }
    
    func requestMonthTodoList(year: String,
                              month: String,
                              _ categoryList: [Int],
                              favorite: Int,
                              completionHandler: @escaping (DataResponse<[MonthTodoData]>) -> Void) {
        
        var listString = ""
        var monthString = month
        
        if categoryList.count != 0 {
            for category in 0..<categoryList.count - 1 {
                listString.append("\(String(categoryList[category])),")
            }
            listString.append(String(categoryList[categoryList.endIndex - 1]))
        }
        
        if monthString.count == 1 {
            monthString.insert("0", at: monthString.startIndex)
        }
        
        guard let token
            = KeychainWrapper.standard.string(forKey: TokenName.token),
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.monthTodoList(year: year,
                                                                     month: monthString,
                                                                     list: listString,
                                                                     favorite: favorite).getRequestURL),
            let request
            = requestMaker.makeRequest(url: url,
                                       method: .get,
                                       header: ["Authorization": token],
                                       body: nil) else {
            return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(MonthTodoList.self,
                                                            from: data)
                    
                    guard let posterData = response.data else {
                        completionHandler(.failed(NSError(domain: "data is nil",
                                                          code: 0,
                                                          userInfo: nil)))
                        return
                    }
                    
                    completionHandler(.success(posterData))
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
    
    func requestDayTodoList(year: String,
                            month: String,
                            day: String,
                            completionHandler: @escaping (DataResponse<[DayTodoData]>) -> Void) {
        
        guard let token
            = KeychainWrapper.standard.string(forKey: TokenName.token),
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.dayTodoList(year: year,
                                                                   month: month,
                                                                   day: day).getRequestURL),
            let request
            = requestMaker.makeRequest(url: url,
                                       method: .get,
                                       header: ["Authorization": token],
                                       body: nil) else {
            return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(DayTodoList.self,
                                                            from: data)
                    
                    guard let posterData = response.data else { return }
                    
                    completionHandler(.success(posterData))
                    
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
    
    func requestTodoDelete(_ posterIdxs: [Int],
                           completionHandler: @escaping (DataResponse<HttpStatusCode>) -> Void) {
        let bodyData = ["posterIdxList": posterIdxs]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyData)
        
        guard let token
            = KeychainWrapper.standard.string(forKey: TokenName.token),
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.deletePoster.getRequestURL),
            let request
            = requestMaker.makeRequest(url: url,
                                       method: .delete,
                                       header: ["Authorization": token,
                                                "Content-Type": "application/json"],
                                       body: jsonData) else {
            return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try JSONDecoder().decode(BasicResponse.self,
                                                               from: data)
                    
                    guard let status = decodedData.status,
                        let httpStatusCode = HttpStatusCode(rawValue: status) else {
                            return
                    }
                    
                    completionHandler(DataResponse.success(httpStatusCode))
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
    
    func requestTodoListClickRecord(_ posterIdx: Int,
                                    type: Int,
                                    completionHandler: @escaping (DataResponse<HttpStatusCode>) -> Void) {
        guard let token
            = KeychainWrapper.standard.string(forKey: TokenName.token),
            let url
            = UserAPI.sharedInstance.getURL(RequestURL.clickRecord(posterIdx: posterIdx,
                                                                   type: type).getRequestURL),
            let request
            = requestMaker.makeRequest(url: url,
                                       method: .post,
                                       header: ["Authorization": token],
                                       body: nil) else {
                                        return
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try JSONDecoder().decode(BasicResponse.self,
                                                               from: data)
                    
                    guard let status = decodedData.status,
                        let httpStatusCode = HttpStatusCode(rawValue: status) else {
                            return
                    }
                    
                    completionHandler(DataResponse.success(httpStatusCode))
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
