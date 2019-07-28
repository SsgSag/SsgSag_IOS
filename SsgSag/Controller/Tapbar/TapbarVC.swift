//
//  TapbarVC.swift
//  SsgSag
//
//  Created by admin on 01/01/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class TapbarVC: UITabBarController {
    
    private let tapbarServiceImp: TabbarService
        = DependencyContainer.shared.getDependency(key: .tabbarService)
    
    struct CreateViewController {
        static let mypageStoryBoard = UIStoryboard(name: StoryBoardName.mypage, bundle: nil)
        
        static let swipeStoryBoard = UIStoryboard(name: StoryBoardName.swipe, bundle: nil)
        
        static let feedStoryBoard = UIStoryboard(name: StoryBoardName.feed, bundle: nil)
        
        static let newCalendarStoryboard = UIStoryboard(name: StoryBoardName.newCalendar, bundle: nil)
        
        static let swipeViewController = swipeStoryBoard.instantiateViewController(withIdentifier: "swipeNavigationVC")
        
        static let feedViewController = feedStoryBoard.instantiateViewController(withIdentifier: "feedNavigationVC")
        
        static let newCalendarViewController = newCalendarStoryboard.instantiateViewController(withIdentifier: "calendarNavigationVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        isServerAvaliable()
        
        setTabBarViewController()
        
        setTabBarStyle()
        
        UIView.appearance().isExclusiveTouch = true
    }
    
    private func setupLayout() {
        tabBar.frame.size.height = 48
    }

    // 서버가 유효한지 확인하는 메소드
    private func isServerAvaliable() {
        tapbarServiceImp.requestIsInUpdateServer{ [weak self] dataResponse in
            guard let data = dataResponse.value?.data else { return }
            
            if data == 1 {
                self?.simplerAlert(title: "서버 업데이트 중입니다.")
            }
        }
    }
    
    private func setTabBarViewController() {
        let swipeViewController = CreateViewController.swipeViewController
        swipeViewController.tabBarItem = UITabBarItem(title: "",
                                                      image: UIImage(named: "icMain"),
                                                      selectedImage: UIImage(named: "icMainActive"))
        
        let mypageViewController = CreateViewController.feedViewController
        mypageViewController.tabBarItem = UITabBarItem(title: "",
                                                       image: UIImage(named: "ic_feedPassive@tabBar"),
                                                       selectedImage: UIImage(named: "ic_feed@tabBar"))
        
        let calendarViewController = CreateViewController.newCalendarViewController
        calendarViewController.tabBarItem = UITabBarItem(title: "",
                                                         image: UIImage(named: "icCal"),
                                                         selectedImage: UIImage(named: "icCalActive"))
        
        let tabBarList = [mypageViewController, swipeViewController, calendarViewController]
        
        self.viewControllers = tabBarList
    }
    
    private func setTabBarStyle() {
        self.tabBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.barStyle = .black
        
        self.selectedIndex = 1
    }
    
}




