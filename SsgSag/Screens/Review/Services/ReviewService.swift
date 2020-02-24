//
//  ReviewService.swift
//  SsgSag
//
//  Created by 남수김 on 2020/02/07.
//  Copyright © 2020 wndzlf. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

class ReviewService: ReviewServiceProtocol {
    private let requestMaker: RequestMakerProtocol = RequestMaker()
    private let network: Network = NetworkImp()
    
    func requestExistClubReviewPost(model: ClubActInfoModel, completion: @escaping (Bool) -> Void) {
        let baseURL = UserAPI.sharedInstance.getBaseString()
        let path = RequestURL.registerReview.getRequestURL
        guard let url = URL(string: baseURL+path) else {return}
        guard let token = KeychainWrapper.standard.string(forKey: TokenName.token) else {return}
        
        let header: [String : String] = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        let body: [String : Any] = [
            "clubStartDate": model.startRequestDate,
            "clubEndDate": model.endRequestDate,
            "score0": model.recommendScore,
            "score1": model.proScore,
            "score2": model.funScore,
            "score3": model.hardScore,
            "score4": model.friendScore,
            "oneLine": model.oneLineString,
            "advantage": model.advantageString,
            "disadvantage": model.disadvantageString,
            "honeyTip": model.honeyString,
            "clubIdx": model.clubIdx
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        guard let request = requestMaker.makeRequest(url: url, method: .post, header: header, body: jsonData) else {return}
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                if let object = try? JSONDecoder().decode(ResponseSimpleResult<String>.self, from: data) {
                    if object.status == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            case .failure(let err):
                print(err.localizedDescription)
                 completion(false)
            }
        }
    }
    
    func requestNonExistClubReviewPost(model: ClubActInfoModel, completion: @escaping (Bool) -> Void) {
        
        let baseURL = UserAPI.sharedInstance.getBaseString()
        let path = RequestURL.registerReview.getRequestURL
        guard let url = URL(string: baseURL+path) else {return}
        guard let token = KeychainWrapper.standard.string(forKey: TokenName.token) else {return}
        
        let header: [String : String] = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        let type = model.clubType == .Union ? 0 : 1
        let univOrLocation: String = model.clubType == .Union ? model.location.value : model.univName
        let body: [String : Any] = [
            "clubType": type,
            "univOrLocation": univOrLocation,
            "clubName": model.clubName,
            "categoryList": model.categoryListToString(),
            "clubStartDate": model.startRequestDate,
            "clubEndDate": model.endRequestDate,
            "score0": model.recommendScore,
            "score1": model.proScore,
            "score2": model.funScore,
            "score3": model.hardScore,
            "score4": model.friendScore,
            "oneLine": model.oneLineString,
            "advantage": model.advantageString,
            "disadvantage": model.disadvantageString,
            "honeyTip": model.honeyString
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        guard let request = requestMaker.makeRequest(url: url, method: .post, header: header, body: jsonData) else {return}
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                if let object = try? JSONDecoder().decode(ResponseSimpleResult<String>.self, from: data) {
                    if object.status == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            case .failure(let err):
                print(err.localizedDescription)
                 completion(false)
            }
        }
    }
    
    func requestReviewList(clubIdx: Int, curPage: Int, completion: @escaping ([ReviewInfo]?) -> Void) {
        let baseURL = UserAPI.sharedInstance.getBaseString()
        let path = RequestURL.searchReviewList(clubIdx: clubIdx, curPage: curPage).getRequestURL
        guard let url = URL(string: baseURL+path) else {return}
        guard let token = KeychainWrapper.standard.string(forKey: TokenName.token) else {return}
        
        let header: [String : String] = [
            "Authorization": token
        ]
        
        guard let request = requestMaker.makeRequest(url: url, method: .get, header: header, body: nil) else {return}
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                if let object = try? JSONDecoder().decode(ResponseArrayResult<ReviewInfo>.self, from: data) {
                    if object.status == 200 {
                        completion(object.data)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            case .failure(let err):
                print(err.localizedDescription)
                 completion(nil)
            }
        }
    }
    
    func requestPostLike(clubPostIdx: Int, completion: @escaping (Bool) -> Void) {
        let baseURL = UserAPI.sharedInstance.getBaseString()
        let path = RequestURL.reviewLike(clubPostIdx: clubPostIdx).getRequestURL
        guard let url = URL(string: baseURL+path) else {return}
        guard let token = KeychainWrapper.standard.string(forKey: TokenName.token) else {return}
        
        let header: [String : String] = [
            "Authorization": token
        ]
        
        guard let request = requestMaker.makeRequest(url: url, method: .post, header: header, body: nil) else {return}
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                if let object = try? JSONDecoder().decode(ResponseSimpleResult<String>.self, from: data) {
                    if object.status == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            case .failure(let err):
                print(err.localizedDescription)
                 completion(false)
            }
        }
    }
    
    func requestDeleteLike(clubPostIdx: Int, completion: @escaping (Bool) -> Void) {
        let baseURL = UserAPI.sharedInstance.getBaseString()
        let path = RequestURL.reviewLike(clubPostIdx: clubPostIdx).getRequestURL
        guard let url = URL(string: baseURL+path) else {return}
        guard let token = KeychainWrapper.standard.string(forKey: TokenName.token) else {return}
        
        let header: [String : String] = [
            "Authorization": token
        ]
        
        guard let request = requestMaker.makeRequest(url: url, method: .delete, header: header, body: nil) else {return}
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                if let object = try? JSONDecoder().decode(ResponseSimpleResult<String>.self, from: data) {
                    if object.status == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            case .failure(let err):
                print(err.localizedDescription)
                 completion(false)
            }
        }
    }
    
    func requestBlogReviewList(keyword: String, count: Int, completion: @escaping () -> Void) {
//        guard let path = RequestURL.searchBlogReivewList(keyword: keyword, count: count).getRequestURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//            return
//        }
//
//        guard let url = URL(string: path) else {return}
//        let header: [String: String] = [
//            "X-Naver-Client-Id" : ClientKey.naverBlogSearchId.getClienyKey,
//            "X-Naver-Client-Secret" : ClientKey.naverBlogSearchSecret.getClienyKey
//        ]
//        print("\n\(url)")
//        guard let request = requestMaker.makeRequest(url: url, method: .get, header: header, body: nil) else {return}
//        network.dispatch(request: request) { result in
//            switch result {
//            case .success(let data):
//
//                guard let test = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {return}
//                print("\ndata-\(data)")
//                guard let temp = test["items"] as? NSArray else {return}
//                guard let item = temp[0] as? NSDictionary else {return}
//                print("\ntest-\(item["description"])")
//                if let object = try? JSONDecoder().decode(Blog.self, from: data) {
//                    print("\nobject-\(object)")
//                    completion()
//                } else {
//                    completion()
//                    print("\n실패!!!")
//                }
//            case .failure(let err):
//                print(err.localizedDescription)
//                 completion()
//            }
//        }
    }
}
