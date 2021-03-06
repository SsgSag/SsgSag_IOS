//
//  SplashViewController.swift
//  SsgSag
//
//  Created by 이혜주 on 31/07/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
//import AdBrixRM
import FBSDKCoreKit
import Adjust

class SplashViewController: UIViewController {

    private let loginServiceImp: LoginService
        = DependencyContainer.shared.getDependency(key: .loginService)
    
    private let signUpService: SignupService
        = DependencyContainer.shared.getDependency(key: .signUpService)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func eventLog() {
        AppEvents.logEvent(AppEvents.Name("TUTORIALS_OPEN"))
        let event = ADJEvent(eventToken: AdjustTokenName.TUTORIALS_OPEN.getTokenString)
        Adjust.trackEvent(event)
    }
    
    @IBAction func touchUpLookAroundButton(_ sender: UIButton) {
        guard let UUID = KeychainWrapper.standard.string(forKey: "UUID") else {
            return
        }
        eventLog()
        let userInfo: [String: Any]
            = ["uuid" : UUID,
               "signupType" : 11,
               "osType" : 1]
        
        signUpService.requestSingup(userInfo) { [weak self] result in
            switch result {
            case .success(let signUpData):
                guard let status = signUpData.status,
                    let statusCode = HttpStatusCode(rawValue: status) else {
                        return
                }
                
                switch statusCode {
                case .sucess:
                    // 로그인 성공
                    guard let storeToken = signUpData.data?.token else {
                        return
                    }
                    
                    KeychainWrapper.standard.set(storeToken, forKey: TokenName.token)
                    
                    UserDefaults.standard.set(true, forKey: "isTryWithoutLogin")
                    UserDefaults.standard.setValue(false, forKey: UserDefaultsName.isAutoLogin)
                    
                    DispatchQueue.main.async {
                        let tapBarVC = TabBarViewController()
                        tapBarVC.modalPresentationStyle = .fullScreen
                        self?.present(tapBarVC, animated: true, completion: nil)
                    }
                case .secondSucess:
                    // 화원가입 성공
                    guard let storeToken = signUpData.data?.token else {
                        return
                    }
                    KeychainWrapper.standard.set(storeToken, forKey: TokenName.token)
                    UserDefaults.standard.set(true, forKey: "isTryWithoutLogin")
                    
                    DispatchQueue.main.async {
                        let tapBarVC = TabBarViewController()
                        tapBarVC.modalPresentationStyle = .fullScreen
                        self?.present(tapBarVC, animated: true, completion: nil)
                        return
                    }
                case .requestError:
                    DispatchQueue.main.async {
                        self?.simplerAlert(title: "요청에 실패하였습니다.")
                        return
                    }
                case .dataBaseError:
                    DispatchQueue.main.async {
                        self?.simplerAlert(title: "database error")
                        return
                    }
                case .serverError:
                    DispatchQueue.main.async {
                        self?.simplerAlert(title: "server error")
                        return
                    }
                default:
                    return
                }
                
            case .failed(let error):
                print(error)
                return
            }
        }
    }
    
    @IBAction func touchUpSelfLoginButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryBoardName.login,
                                      bundle: nil)
        let selfLoginVC
            = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifier.loginViewController)
        
        navigationController?.pushViewController(selfLoginVC,
                                                 animated: true)
    }
    
    @IBAction func touchUpKakaoLoginButton(_ sender: UIButton) {
        
        let session = KOSession.shared() //세션 생성
        
        guard let kakaoSession = session else {
            print("no session")
            return
        }
        
        if kakaoSession.isOpen() {//세션이 인증되어있는지 확인
            kakaoSession.close()
        }
        
        kakaoSession.open { [weak self] (error) in
            guard error == nil else {
                return
            }
            
            if kakaoSession.isOpen() {
                
                //self.postData(accessToken: kakaoSession.token.accessToken, loginType: 0)
                
                self?.loginServiceImp.requestSnsLogin(
                    using: kakaoSession.token.accessToken,
                    type: 0
                ) { [weak self] (dataResponse) in
                    switch dataResponse {
                    case .success(let response):
                        if let storeToken = response.data?.token {
                            KeychainWrapper.standard.set(storeToken,
                                                         forKey: TokenName.token)
                        }
                        
                        UserDefaults.standard.set(false, forKey: "isTryWithoutLogin")
                        
                        DispatchQueue.main.async {
                            switch response.status {
                            case 200:
                                guard let token = response.data?.token else {
                                    return
                                }
                                
//                                let adBrix = AdBrixRM.getInstance
//                                
//                                // 로그인이 성공했을 때, 토큰 전달
//                                adBrix.login(userId: token)
//                                
                                let tapBarVC = TabBarViewController()
                                tapBarVC.modalPresentationStyle = .fullScreen
                                self?.present(tapBarVC, animated: true, completion: nil)
                            case 404:
                                let storyboard = UIStoryboard(name: StoryBoardName.signup, bundle: nil)
                                
                                guard let signupVC = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifier.schoolInfoViewController) as? SchoolInfoVC else {
                                    return
                                }

                                signupVC.isSnsLogin = true
                                
                                let signupNavigator = UINavigationController(rootViewController: signupVC)
                                
                                signupNavigator.modalPresentationStyle = .fullScreen
                                self?.present(signupNavigator, animated: true, completion: nil)
                            default:
                                break
                            }
                        }
                    case .failed(let error):
                        print(error)
                        return
                    }
                }
            } else {
                print("fail")
            }
        }
    }
    
}
