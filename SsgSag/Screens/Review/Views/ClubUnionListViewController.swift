//
//  ClubUnionListViewController.swift
//  SsgSag
//
//  Created by 남수김 on 2020/02/15.
//  Copyright © 2020 wndzlf. All rights reserved.
//

import UIKit

class ClubUnionListViewController: UIViewController {
    @IBOutlet weak var reviewTableView: UITableView!
    var pageIndex = 1
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
            
            data.filter{ $0.clubType == 0}
                .forEach { self.cellData.append($0) }
            self.reviewTableView.reloadData()
        }
    }
}

extension ClubUnionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for: indexPath) as! ClubListTableViewCell
        
        cell.viewModel = cellData[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - Table Delegate
extension ClubUnionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.cellData.count-1 {
            self.curPage += 1
            self.requestPage()
        }
    }
}

// MARK: - Extension
extension ClubUnionListViewController: ClubListSelectDelgate {
    func clubDetailClick(clubIdx: Int) {
          let nextVC = UIStoryboard(name: "Review", bundle: nil).instantiateViewController(withIdentifier: "ClubDetailVC") as! ClubDetailViewController
              nextVC.clubIdx = clubIdx
        nextVC.tabViewModel = ClubDetailViewModel()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}