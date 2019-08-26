//
//  SplashVC.swift
//  SsgSag
//
//  Created by CHOMINJI on 2019. 1. 4..
//  Copyright © 2019년 wndzlf. All rights reserved.
//
import UIKit
import Lottie
import SwiftKeychainWrapper

class SplashVC: UIViewController {
    
    private let animation = LOTAnimationView(name: "splash")
    private var nextViewController = UIViewController()
    
    private let tapbarServiceImp: TabbarService
        = DependencyContainer.shared.getDependency(key: .tabbarService)
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bgSplash")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isServerAvaliable()
        
        setupLayout()
        setupNextViewController()
        
        animation.play { [weak self] _ in
            guard let self = self else {
                return
            }
            self.present(self.nextViewController, animated: true)
        }
    }
    
    private func setupLayout() {
        
        view.addSubview(backgroundImageView)
        view.addSubview(animation)
        
        backgroundImageView.topAnchor.constraint(
            equalTo: view.topAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor).isActive = true
        
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        animation.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        animation.topAnchor.constraint(
            equalTo: view.topAnchor).isActive = true
        animation.leadingAnchor.constraint(
            equalTo: view.leadingAnchor).isActive = true
        animation.trailingAnchor.constraint(
            equalTo: view.trailingAnchor).isActive = true
        animation.bottomAnchor.constraint(
            equalTo: view.bottomAnchor).isActive = true
        
    }
    
    private func setupNextViewController() {
        
        if let isAutoLogin
            = UserDefaults.standard.object(forKey: UserDefaultsName.isAutoLogin) as? Bool {
            if isAutoLogin {
                if isTokenExist() {
                    nextViewController = TapbarVC()
                } else {
                    let loginStoryBoard = UIStoryboard(name: StoryBoardName.login,
                                                       bundle: nil)
                    let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "splashVC")
                    
                    nextViewController = UINavigationController(rootViewController: loginVC)
                }
            } else {
                let loginStoryBoard = UIStoryboard(name: StoryBoardName.login,
                                                   bundle: nil)
                let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "splashVC")
                
                nextViewController = UINavigationController(rootViewController: loginVC)
            }
        } else {
            let loginStoryBoard = UIStoryboard(name: StoryBoardName.login,
                                               bundle: nil)
            let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "splashVC")
            nextViewController = UINavigationController(rootViewController: loginVC)
        }
    }
    
    private func isTokenExist() -> Bool {
        if KeychainWrapper.standard.string(forKey: TokenName.token) != nil {
            return true
        } else {
            return false
        }
    }
    
    // 서버가 유효한지 확인하는 메소드
    private func isServerAvaliable() {
        tapbarServiceImp.requestIsInUpdateServer{ [weak self] dataResponse in
            switch dataResponse {
            case .success(let data):
                guard data.data == 0 else {
                    self?.simpleAlertwithHandler(title: "",
                                                 message: "서버 업데이트 중입니다.",
                                                 okHandler: { _ in
                                                    exit(0)
                    })
                    return
                }
            case .failed(let error):
                print(error)
                self?.simpleAlertwithHandler(title: "",
                                             message: "서버 업데이트 중입니다.",
                                             okHandler: { _ in
                                                exit(0)
                })
                return
            }
        }
    }
}

