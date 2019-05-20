//
//  TapbarVC.swift
//  SsgSag
//
//  Created by admin on 01/01/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class TapbarVC: UITabBarController {
    
    private var tapbarServiceImp: TapbarService? = TapbarServiceImp()
    
    struct CreateViewController {
        
        static let swipeStoryBoard = UIStoryboard(name: StoryBoardName.swipe, bundle: nil)
        
        static let mypageStoryBoard = UIStoryboard(name: StoryBoardName.mypage, bundle: nil)
        
        static let swipeViewController = swipeStoryBoard.instantiateViewController(withIdentifier: ViewControllerIdentifier.swipe)
        
        static let mypageViewController = mypageStoryBoard.instantiateViewController(withIdentifier: ViewControllerIdentifier.mypageViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isServerAvaliable()
        
        setTabBarViewControllers()
        
        setTabBarStyle()
        
        getPostersAndStore()
    }
    
    private func isServerAvaliable() {
        tapbarServiceImp?.requestIsInUpdateServer{ (dataResponse) in
            guard let data = dataResponse.value?.data else {return}
            
            if data == 1 {
                self.simplerAlert(title: "서버 업데이트 중입니다.")
            }
        }
    }
    
    private func setTabBarViewControllers() {
        let swipeViewController = CreateViewController.swipeViewController
        swipeViewController.tabBarItem = UITabBarItem(title: "",
                                                      image: UIImage(named: "icMain"),
                                                      selectedImage: UIImage(named: "icMainActive"))
        
        let mypageViewController = CreateViewController.mypageViewController
        mypageViewController.tabBarItem = UITabBarItem(title: "",
                                                       image: UIImage(named: "icUser"),
                                                       selectedImage: UIImage(named: "icUserActive"))
        
        let calendarViewController = CalenderVC()
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
    
    /// start only at first time
    private func getPostersAndStore() {
        
        guard let _ = UserDefaults.standard.object(forKey: UserDefaultsName.syncWithLocalData) as? Bool else {
            
            let start = true
            
            UserDefaults.standard.setValue(start, forKey: UserDefaultsName.syncWithLocalData)
            
            syncDataAtFirst()
            
            return
        }
    }
    
    private func syncDataAtFirst() {
        
        tapbarServiceImp?.requestAllTodoList { (dataResponse) in
            
            guard let todoList = dataResponse.value else { return }
        
            StoreAndFetchPoster.storePoster(posters: todoList)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        var tabFrame:CGRect = self.tabBar.frame
        tabFrame.origin.y = self.view.safeAreaInsets.top - 8
        let barHeight: CGFloat = 56
        tabFrame.size.height = barHeight
        self.tabBar.frame = tabFrame
        
        UIView.appearance().isExclusiveTouch = true
    }
}




