//
//  ClubReviewVC+Extension.swift
//  SsgSag
//
//  Created by 남수김 on 2020/01/29.
//  Copyright © 2020 wndzlf. All rights reserved.
//

import Foundation
import UIKit

extension ClubReviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if normalReviewTableView == tableView {
            return self.reviewDataSet.count
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if normalReviewTableView == tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalReviewCell", for: indexPath) as! NormalReviewTableViewCell
            
            cell.viewModel = self.reviewDataSet[indexPath.row]
            cell.moreButton.tag = indexPath.row
            cell.moreButton.addTarget(self, action: #selector(moreViewSelect(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlogReviewCell", for: indexPath) as! BlogReviewTableViewCell
            
            return cell
        }
    }
}