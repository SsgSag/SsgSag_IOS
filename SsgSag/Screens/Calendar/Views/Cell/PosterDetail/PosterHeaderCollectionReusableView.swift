//
//  PosterHeaderCollectionReusableView.swift
//  SsgSag
//
//  Created by 이혜주 on 18/07/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

protocol LargeImageDelegate: class {
    func presentLargeImage()
}

class PosterHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var posterTitleLabel: UILabel!
    
    @IBOutlet weak var hashTagLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: LargeImageDelegate?
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: nil)
    
    var detailData: DataClass? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapGesture.delegate = self
        posterImageView.addGestureRecognizer(tapGesture)
        
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = 26
        
        let titleAttrString = NSMutableAttributedString()
        titleAttrString.addAttributes([.paragraphStyle : titleStyle],
                                      range: NSMakeRange(0, titleAttrString.length))
        posterTitleLabel.attributedText = titleAttrString
        
        
        let hashStyle = NSMutableParagraphStyle()
        hashStyle.lineSpacing = 20
        
        let hashAttrString = NSMutableAttributedString()
        hashAttrString.addAttributes([.paragraphStyle : hashStyle],
                                     range: NSMakeRange(0, hashAttrString.length))
        hashTagLabel.attributedText = hashAttrString
        
    }

    func configure() {
        guard let data = detailData,
            let categoryIdx = data.categoryIdx else { return }
        
        if let category = PosterCategory(rawValue: categoryIdx) {
            var categoryString = category.categoryString()
            
            if categoryIdx == 2 {
                let subCategory = data.subCategoryIdx == 0 ? "연합" : "교내"
                categoryString.append("(\(subCategory))")
            }
            
            categoryButton.setTitle(categoryString, for: .normal)
            categoryButton.setTitleColor(category.categoryColors(), for: .normal)
            categoryButton.backgroundColor = category.categoryColors().withAlphaComponent(0.05)
        }
        
        if data.favoriteNum != nil {
            let favoriteString = String(data.favoriteNum!)
            favoriteButton.setTitle(favoriteString, for: .normal)
        }
        
        if data.likeNum != nil {
            let likeString = String(data.likeNum!)
            likeButton.setTitle(likeString, for: .normal)
        }
        
        hashTagLabel.text = data.keyword
        
        posterTitleLabel.text = data.posterName
        //        outLineLabel.text = detailData.outline
        //        targetLabel.text = detailData.target
        //        benefitLabel.text = detailData.benefit
        //        seeMoreLabel.text = detailData.posterDetail
    }
}

extension PosterHeaderCollectionReusableView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        delegate?.presentLargeImage()
        return true
    }
}
