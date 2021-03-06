//
//  RequestURL.swift
//  SsgSag
//
//  Created by admin on 21/04/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

enum RequestURL {
    case posterLiked(posterIdx: Int, likeType: Int)
    case initPoster
    case login
    case snsLogin
    case autoLogin
    case favorite(posterIdx: Int)
    case deletePoster
    case monthTodoList(year: String, month: String, list: String, favorite: Int)
    case dayTodoList(year: String, month: String, day: String)
    case posterDetail(posterIdx: Int)
    case posterWhat(category: Int)
    case interestingField
    case reIntersting
    case careerActivity
    case deleteAcitivity(careerIdx: Int)
    case subscribeInterest
    case subscribeAddOrDelete(interestIdx: Int)
    case signUp
    case validateNickname
    case isUpdate(version: String)
    case career(careerType: Int)
    case notice
    case tempPassword
    case changePassword
    case updatePhoto
    case feed
    case feedLookUp(posterIndex: Int)
    case scrap(index: Int)
    case comment
    case commentLike(index: Int, like: Int)
    case commentDelete(index: Int)
    case commentReport(index: Int)
    case allPoster(category: Int, sortType: Int, curPage: Int)
    case clickRecord(posterIdx: Int, type: Int)
    
    var getRequestURL: String {
        switch self {
        case .posterLiked(let posterIdx,
                          let like):
            return "/poster/like?posterIdx=\(posterIdx)&like=\(like)"
        case .initPoster:
            return "/poster"
        case .login:
            return "/login2"
        case .snsLogin:
            return "/login"
        case .autoLogin:
            return "/autoLogin"
        case .favorite(let posterIdx):
            return "/todo/favorite/\(posterIdx)"
        case .deletePoster:
            return "/todo"
        case .monthTodoList(let year,
                            let month,
                            let list,
                            let favorite):
            return "/todo?year=\(year)&month=\(month)&day=00&categoryList=\(list)&favorite=\(favorite)"
        case .dayTodoList(let year,
                          let month,
                          let day):
            return "/todo?year=\(year)&month=\(month)&day=\(day)"
        case .posterDetail(let posterIdx):
            return "/poster/\(posterIdx)"
        case .posterWhat(let category):
            return "/poster/what?category=\(category)"
        case .interestingField:
            return "/user/interest"
        case .reIntersting:
            return "/user/reInterest"
        case .careerActivity:
            return "/career"
        case .deleteAcitivity(let careerIdx):
            return "/career/\(careerIdx)"
        case .subscribeInterest:
            return "/user/subscribe"
        case .subscribeAddOrDelete(let interestIdx):
            return "/user/subscribe/\(interestIdx)"
        case .signUp:
            return "/user"
        case .validateNickname:
            return "/user/validateNickname"
        case .tempPassword:
            return "/user/tempPassword"
        case .changePassword:
            return "/user/rePassword"
        case .updatePhoto:
            return "/user/photo"
        case .isUpdate(let version):
            return "/update?osType=ios&version=\(version)"
        case .career(let careerType):
            return "/career/\(careerType)"
        case .notice:
            return "/notice"
        case .feed:
            return "/feed"
        case .feedLookUp(let posterIndex):
            return "/feed/\(posterIndex)"
        case .scrap(let index):
            return "/feed/\(index)"
        case .comment:
            return "/comment"
        case .commentLike(let index,
                          let like):
            return "/comment/like/\(index)/\(like)"
        case .commentDelete(let index):
            return "/comment/\(index)"
        case .commentReport(let index):
            return "/comment/caution/\(index)"
        case .allPoster(let category,
                        let sortType,
                        let curPage):
            return "/poster/all?category=\(category)&sortType=\(sortType)&curPage=\(curPage)"
        case .clickRecord(let posterIdx,
                          let type):
            return "/todo/click/\(posterIdx)/\(type)"
        }
    }
    
}
