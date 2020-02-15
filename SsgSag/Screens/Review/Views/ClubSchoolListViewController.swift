//
//  ClubReviewViewController.swift
//  SsgSag
//
//  Created by 남수김 on 2020/01/23.
//  Copyright © 2020 wndzlf. All rights reserved.
//

import UIKit

class ClubSchoolListViewController: UIViewController {
    @IBOutlet weak var reviewTableView: UITableView!
    var pageIndex = 0
    var curPage = 0
    var cellData: [ClubListData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reviewTableView.dataSource = self
        self.reviewTableView.delegate = self
        self.reviewTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshPage()
    }
    
    func refreshPage() {
        curPage = 0
        cellData.removeAll()
        self.reviewTableView.reloadData()
        requestPage()
    }
    
    func requestPage() {
        ClubService().requestClubList(curPage: curPage) { data in
            guard let data = data else { return }
            if data.count == 0 {
                self.curPage -= 1
                return
            }
            
            data.filter{ $0.clubType == 1}
                .forEach { self.cellData.append($0) }
            self.reviewTableView.reloadData()
        }
    }
    
}