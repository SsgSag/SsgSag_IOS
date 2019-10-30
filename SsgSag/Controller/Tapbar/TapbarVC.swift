//
//  TapbarVC.swift
//  SsgSag
//
//  Created by admin on 01/01/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit
import AdBrixRM

class TapbarVC: UITabBarController {

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var tabBarFrame = self.tabBar.frame
        print(UIScreen.main.bounds.height)
        if UIScreen.main.bounds.height >= 812 {
            tabBarFrame.size.height = 80
            tabBarFrame.origin.y = self.view.frame.size.height - 75
        } else {
            tabBarFrame.size.height = 50
            tabBarFrame.origin.y = self.view.frame.size.height - 45
        }
        self.tabBar.frame = tabBarFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        setTabBarViewController()
        
        setTabBarStyle()
        
        UIView.appearance().isExclusiveTouch = true
    }
    
    private func setupLayout() {
        tabBar.frame.size.height = 48
    }
    
    private func setTabBarViewController() {
        
        let swipeStoryBoard = UIStoryboard(name: StoryBoardName.swipe, bundle: nil)
        
        let feedStoryBoard = UIStoryboard(name: StoryBoardName.feed, bundle: nil)
        
        let newCalendarStoryboard = UIStoryboard(name: StoryBoardName.newCalendar, bundle: nil)
        
        let swipeViewController = swipeStoryBoard.instantiateViewController(withIdentifier: "swipeNavigationVC")
        
        let feedViewController = feedStoryBoard.instantiateViewController(withIdentifier: "feedNavigationVC")
        
        let newCalendarViewController = newCalendarStoryboard.instantiateViewController(withIdentifier: "calendarNavigationVC")
        
        swipeViewController.tabBarItem = UITabBarItem(title: "",
                                                      image: UIImage(named: "icMain"),
                                                      selectedImage: UIImage(named: "icMainActive"))
        
        feedViewController.tabBarItem = UITabBarItem(title: "",
                                                     image: UIImage(named: "ic_feedPassive@tabBar"),
                                                     selectedImage: UIImage(named: "ic_feed@tabBar"))
        
        newCalendarViewController.tabBarItem = UITabBarItem(title: "",
                                                            image: UIImage(named: "ic_calendarPassive"),
                                                            selectedImage: UIImage(named: "ic_calendarActive"))
        
        let tabBarList = [feedViewController, swipeViewController, newCalendarViewController]
        
        self.viewControllers = tabBarList
    }
    
    private func setTabBarStyle() {
        self.tabBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.barStyle = .black
        
        self.selectedIndex = 1
    }
    
}




